#!/usr/bin/env bash
# 主工程运行 / Release 构建
# 用法见: ./scripts/run_app.sh --help
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUILD=false
BUILD_TARGET=""
MODE_ARGS=()
EXTRA_ARGS=()
ENV_FILE="$ROOT/.env"
USE_LAN=false          # true → .env.lan（真机局域网）
LAN_EXPLICIT=false     # 用户显式 --lan / --env-file
START_PLATFORM=""   # android | ios | harmony
DEVICE_ID=""
FORCE_DEBUG=false      # 无线也强制 debug（默认否）

usage() {
  cat <<'EOF'
用法:
  ./scripts/run_app.sh [选项] [flutter run/build 额外参数...]

运行（默认 debug；无线真机自动改 release，避免 LLDB 冻屏）:
  ./scripts/run_app.sh
  ./scripts/run_app.sh -d <device_id>
  ./scripts/run_app.sh --lan -d <真机_id>   # 强制 .env.lan（BACKEND_HOST）
  ./scripts/run_app.sh --android          # 启动 Android 模拟器并 run
  ./scripts/run_app.sh --ios              # 启动 iOS 模拟器并 run
  ./scripts/run_app.sh --harmony          # 启动鸿蒙模拟器并 run
  ./scripts/run_app.sh -r
  ./scripts/run_app.sh --release -d iPhone
  ./scripts/run_app.sh --force-debug -d <无线真机>  # 强制 debug（易冻，需 USB）

平台快捷（会先调用 start_emulator.sh --wait）:
  --android | --and
  --ios | --iphone
  --harmony | --ohos | --hos

局域网真机:
  --lan                使用 --dart-define-from-file=.env.lan
  （对物理机 -d 时若未指定 --env-file，也会自动改用 .env.lan）

Release / Profile 模式:
  -r, --release    flutter run --release（或 build 时显式 release）
  -p, --profile    flutter run --profile（仍会挂调试器，无线勿用）
  --force-debug    无线真机也强制 debug（默认无线会自动切 release）

卡住无法进后台:
  ./scripts/cleanup_ios_debug.sh -d <udid>

构建产物（release 默认）:
  -b, --build TARGET
      android | apk      → flutter build apk
      appbundle | aab    → flutter build appbundle
      ios                → flutter build ios（需 Xcode 签名）
      ipa                → flutter build ipa
      hap | ohos         → flutter build hap（需 OHOS Flutter SDK）

示例:
  ./scripts/run_app.sh --lan -d <iPhone_udid>
  ./scripts/run_app.sh --android
  ./scripts/run_app.sh --ios -r
  ./scripts/run_app.sh --harmony
  ./scripts/run_app.sh -r -d 00008110-xxxxxxxx
  ./scripts/run_app.sh --build apk
  ./scripts/run_app.sh --build hap

说明:
  默认注入 --dart-define-from-file=.env；真机 / --lan 用 .env.lan。
  首次: cp .env.example .env ；真机再: cp .env.lan.example .env.lan
  IDE: 选 launch「my_ai_project (LAN 真机)」即可。
  仅启动模拟器: ./scripts/start_emulator.sh android|ios|harmony
EOF
}

find_flutter() {
  if [[ -n "${FLUTTER_BIN:-}" ]]; then
    echo "$FLUTTER_BIN"
    return
  fi
  local candidates=(
    "$ROOT/.fvm/flutter_sdk/bin/flutter"
    "$HOME/fvm/versions/custom_3.35-ohos/bin/flutter"
    "/Users/mac/fvm/versions/custom_3.35-ohos/bin/flutter"
    "/Users/stvenfor/fvm/default/bin/flutter"
  )
  local c
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then
      echo "$c"
      return
    fi
  done
  command -v flutter
}

prepare_android_env() {
  if [[ -z "${ANDROID_HOME:-}" ]]; then
    local sdk
    for sdk in \
      "$HOME/Library/Android/sdk" \
      "/Users/stvenfor/Library/Android/sdk"; do
      if [[ -d "$sdk" ]]; then
        export ANDROID_HOME="$sdk"
        export ANDROID_SDK_ROOT="$sdk"
        break
      fi
    done
  else
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
  fi
  if [[ "${JAVA_HOME:-}" == "/usr/local/opt/openjdk@17" &&
        ! -d "$JAVA_HOME" ]]; then
    unset JAVA_HOME
  fi
}

ensure_env_file() {
  if [[ -f "$ENV_FILE" ]]; then
    return
  fi
  if [[ "$USE_LAN" == true ]]; then
    cat >&2 <<EOF
错误: 未找到 $ENV_FILE

真机局域网请先:
  cp .env.lan.example .env.lan
并填写 BACKEND_HOST=<Mac 局域网 IP>（与 Go REALTIME_PUBLIC_WS_HOST 相同）。
EOF
  else
    cat >&2 <<EOF
错误: 未找到 $ENV_FILE

请先创建本地配置:
  cp .env.example .env

如果只是本地跑 Mock 登录，可将 .env 中 USE_MOCK_AUTH 改为 true。
如果要联调真实登录，请保持 USE_MOCK_AUTH=false 并启动 my_go_study 后端。
真机局域网请用: ./scripts/run_app.sh --lan -d <device_id>
EOF
  fi
  exit 1
}

# 判断 flutter devices 行是否像物理机（非 simulator / emulator）
device_line_is_physical() {
  local line="$1"
  [[ "$line" != *"(simulator)"* ]] \
    && [[ "$line" != *"emulator-"* ]] \
    && [[ "$line" != *"chrome"* ]] \
    && [[ "$line" != *"macos"* ]]
}

# 若 -d 指向物理机且用户未显式指定 env，改用 .env.lan
maybe_switch_env_for_physical_device() {
  local flutter_bin="$1"
  [[ "$LAN_EXPLICIT" == true ]] && return
  [[ -z "$DEVICE_ID" ]] && return
  [[ ! -f "$ROOT/.env.lan" ]] && return

  local line
  while IFS= read -r line; do
    if [[ "$line" == *"• ${DEVICE_ID} •"* ]] || [[ "$line" == *"• ${DEVICE_ID}"* ]]; then
      if device_line_is_physical "$line"; then
        USE_LAN=true
        ENV_FILE="$ROOT/.env.lan"
        echo "→ 检测到物理设备，使用 --dart-define-from-file=.env.lan"
      fi
      return
    fi
  done < <("$flutter_bin" devices 2>/dev/null || true)
}

start_emulator_for() {
  local platform="$1"
  echo "→ 启动 ${platform} 模拟器..."
  "$ROOT/scripts/start_emulator.sh" "$platform" --wait
}

# 从 flutter devices 解析目标 device id
resolve_device_id() {
  local platform="$1"
  local flutter_bin="$2"
  local line id

  # Prefer machine-readable lines: "<name> • <id> • <platform> • ..."
  while IFS= read -r line; do
    case "$platform" in
      android)
        if [[ "$line" == *"• android"* ]] || [[ "$line" == *emulator-* ]]; then
          id="$(printf '%s\n' "$line" | awk -F ' • ' '{print $2}' | xargs)"
          if [[ -n "$id" && "$id" != "macos" && "$id" != "chrome" ]]; then
            echo "$id"
            return
          fi
        fi
        ;;
      ios)
        if [[ "$line" == *"• ios"* ]] && [[ "$line" != *"wireless"* ]]; then
          id="$(printf '%s\n' "$line" | awk -F ' • ' '{print $2}' | xargs)"
          # Prefer simulator UDID (contains many hyphens / hex)
          if [[ -n "$id" ]]; then
            echo "$id"
            return
          fi
        fi
        ;;
      harmony|ohos)
        if [[ "$line" == *"• ohos"* ]] || [[ "$line" == *"harmony"* ]]; then
          id="$(printf '%s\n' "$line" | awk -F ' • ' '{print $2}' | xargs)"
          if [[ -n "$id" ]]; then
            echo "$id"
            return
          fi
        fi
        ;;
    esac
  done < <("$flutter_bin" devices 2>/dev/null || true)

  return 1
}

wait_flutter_device() {
  local platform="$1"
  local flutter_bin="$2"
  local i=0
  local id=""
  echo "→ 等待 Flutter 识别 ${platform} 设备..."
  while ((i < 90)); do
    if id="$(resolve_device_id "$platform" "$flutter_bin")"; then
      echo "→ 设备: $id"
      DEVICE_ID="$id"
      return
    fi
    sleep 2
    i=$((i + 2))
  done
  echo "错误: Flutter 未识别到 ${platform} 设备。请检查模拟器是否已启动。" >&2
  "$flutter_bin" devices || true
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -r|--release)
      MODE_ARGS+=(--release)
      shift
      ;;
    -p|--profile)
      MODE_ARGS+=(--profile)
      shift
      ;;
    --force-debug)
      FORCE_DEBUG=true
      shift
      ;;
    --android|--and)
      START_PLATFORM=android
      shift
      ;;
    --ios|--iphone)
      START_PLATFORM=ios
      shift
      ;;
    --harmony|--ohos|--hos)
      START_PLATFORM=harmony
      shift
      ;;
    --lan)
      USE_LAN=true
      LAN_EXPLICIT=true
      ENV_FILE="$ROOT/.env.lan"
      shift
      ;;
    --env-file)
      LAN_EXPLICIT=true
      ENV_FILE="${2:-}"
      if [[ -z "$ENV_FILE" ]]; then
        echo "错误: --env-file 需要路径" >&2
        exit 1
      fi
      if [[ "$ENV_FILE" != /* ]]; then
        ENV_FILE="$ROOT/$ENV_FILE"
      fi
      if [[ "$ENV_FILE" == *".env.lan" ]]; then
        USE_LAN=true
      fi
      shift 2
      ;;
    -d)
      DEVICE_ID="${2:-}"
      if [[ -z "$DEVICE_ID" ]]; then
        echo "错误: -d 需要 device id" >&2
        exit 1
      fi
      EXTRA_ARGS+=(-d "$DEVICE_ID")
      shift 2
      ;;
    -b|--build)
      BUILD=true
      BUILD_TARGET="${2:-}"
      if [[ -z "$BUILD_TARGET" ]]; then
        echo "错误: --build 需要指定目标 (apk|android|appbundle|aab|ios|ipa|hap|ohos)" >&2
        exit 1
      fi
      shift 2
      ;;
    build)
      BUILD=true
      BUILD_TARGET="${2:-}"
      if [[ -z "$BUILD_TARGET" ]]; then
        echo "错误: build 需要指定目标 (apk|android|appbundle|aab|ios|ipa|hap|ohos)" >&2
        exit 1
      fi
      shift 2
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

prepare_android_env
FLUTTER="$(find_flutter)"

if [[ -n "$START_PLATFORM" ]]; then
  start_emulator_for "$START_PLATFORM"
  wait_flutter_device "$START_PLATFORM" "$FLUTTER"
  # Avoid duplicate -d if user also passed one
  local_has_d=false
  if ((${#EXTRA_ARGS[@]} > 0)); then
    for a in "${EXTRA_ARGS[@]}"; do
      if [[ "$a" == "-d" ]]; then
        local_has_d=true
        break
      fi
    done
  fi
  if [[ "$local_has_d" == false ]]; then
    EXTRA_ARGS+=(-d "$DEVICE_ID")
  fi
fi

# 物理机 -d 且未显式 --env-file/--lan 时，自动改用 .env.lan
maybe_switch_env_for_physical_device "$FLUTTER"
if [[ "$USE_LAN" == true ]]; then
  SYNC="$ROOT/../my_code_study/my_go_study/scripts/sync-lan-ip.sh"
  if [[ -f "$SYNC" ]]; then
    bash "$SYNC"
  else
    echo "警告: 未找到 $SYNC，沿用现有 .env.lan" >&2
  fi
fi
ensure_env_file
ENV_ARGS=(--dart-define-from-file="$ENV_FILE")
echo "→ dart-define-from-file=$(basename "$ENV_FILE")"

"$FLUTTER" pub get

FLUTTER_PID=""

# Ctrl+C / Warp 中断时：杀 flutter 进程树 + 本机 LLDB + 真机 Runner/debugserver。
# 否则 LLDB start-stopped / debugserver 会把 App 冻住，表现为卡死且无法进后台。
resolve_run_device_id() {
  local i=0
  local a=""
  while ((i < ${#EXTRA_ARGS[@]})); do
    a="${EXTRA_ARGS[$i]}"
    if [[ "$a" == "-d" ]]; then
      echo "${EXTRA_ARGS[$((i + 1))]:-}"
      return 0
    fi
    i=$((i + 1))
  done
  if [[ -n "${DEVICE_ID:-}" ]]; then
    echo "$DEVICE_ID"
    return 0
  fi
  return 1
}

kill_local_debug_attachers() {
  # 先拆本机附加，再动真机（顺序很重要）。
  if [[ -n "${FLUTTER_PID:-}" ]]; then
    pkill -9 -P "$FLUTTER_PID" 2>/dev/null || true
    kill -9 "$FLUTTER_PID" 2>/dev/null || true
  fi
  pkill -9 -f '/Developer/usr/bin/lldb' 2>/dev/null || true
}

terminate_ios_debug_stack() {
  local device="${1:-}"
  [[ -z "$device" ]] && return 0
  command -v xcrun >/dev/null 2>&1 || return 0
  local tmp
  tmp="$(mktemp)"
  if ! xcrun devicectl device info processes \
      --device "$device" --timeout 10 --json-output "$tmp" >/dev/null 2>&1; then
    rm -f "$tmp"
    return 0
  fi
  python3 - "$tmp" "$device" <<'PY'
import json, subprocess, sys
path, device = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path))
except Exception:
    raise SystemExit(0)
procs = (data.get("result") or {}).get("runningProcesses") or []
for p in procs:
    exe = str(p.get("executable") or "")
    pid = p.get("processIdentifier")
    if not pid:
        continue
    if "/Runner.app/Runner" not in exe and "/usr/libexec/debugserver" not in exe and not exe.rstrip("/").endswith("/debugserver"):
        continue
    print(f"→ 中断清理: kill pid={pid} {exe}")
    for args in (
        ["xcrun", "devicectl", "device", "process", "resume", "--device", device, "--pid", str(pid), "--timeout", "5"],
        ["xcrun", "devicectl", "device", "process", "terminate", "--device", device, "--pid", str(pid), "--kill", "--timeout", "8"],
        ["xcrun", "devicectl", "device", "process", "signal", "--device", device, "--pid", str(pid), "--signal", "SIGKILL", "--timeout", "8"],
    ):
        subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PY
  rm -f "$tmp"
}

on_interrupt() {
  echo "" >&2
  echo "→ 收到中断，拆掉 LLDB/debugserver（避免真机冻屏无法进后台）…" >&2
  kill_local_debug_attachers
  # 给 debugserver 一点时间随 lldb 退出
  sleep 0.5
  local device=""
  device="$(resolve_run_device_id || true)"
  if [[ -n "$device" ]]; then
    terminate_ios_debug_stack "$device"
  fi
  exit 130
}

# bash 3.2 + set -u 下空数组 "${arr[@]}" 会报 unbound variable，需先判长度。
run_flutter() {
  local -a cmd=("$FLUTTER" "$@")
  if ((${#ENV_ARGS[@]} > 0)); then cmd+=("${ENV_ARGS[@]}"); fi
  if ((${#MODE_ARGS[@]} > 0)); then cmd+=("${MODE_ARGS[@]}"); fi
  if ((${#EXTRA_ARGS[@]} > 0)); then cmd+=("${EXTRA_ARGS[@]}"); fi
  # 不用 exec：保留 trap，才能在 Warp/终端中断时清理冻住的真机进程。
  if [[ "$1" == "run" ]]; then
    trap on_interrupt INT TERM
    # 新建进程组，便于一次杀掉 flutter + 子进程 lldb
    set -m
    "${cmd[@]}" &
    FLUTTER_PID=$!
    set +m
    wait "$FLUTTER_PID"
    local ec=$?
    trap - INT TERM
    # 正常退出也扫一眼，防止残留 debugserver
    if [[ "$ec" -ne 0 ]]; then
      kill_local_debug_attachers
      local device=""
      device="$(resolve_run_device_id || true)"
      [[ -n "$device" ]] && terminate_ios_debug_stack "$device"
    fi
    return "$ec"
  fi
  "${cmd[@]}"
}

if [[ "$BUILD" == true ]]; then
  case "$BUILD_TARGET" in
    android|apk)
      run_flutter build apk
      ;;
    appbundle|aab)
      run_flutter build appbundle
      ;;
    ios)
      run_flutter build ios
      ;;
    ipa)
      run_flutter build ipa
      ;;
    hap|ohos|harmony)
      run_flutter build hap
      ;;
    *)
      echo "未知构建目标: $BUILD_TARGET" >&2
      echo "支持: apk, android, appbundle, aab, ios, ipa, hap, ohos" >&2
      exit 1
      ;;
  esac
else
  # 无线真机：debug/profile 都会挂 lldb+debugserver，卡死且无法进后台。
  # 只有 --release 走 DebuggingOptions.disabled（纯 install+launch）。
  # 默认自动切 release；要热重载请 USB + --force-debug。
  _mode_joined=" "
  if ((${#MODE_ARGS[@]} > 0)); then
    _mode_joined=" ${MODE_ARGS[*]} "
  fi
  _needs_debugger=true
  if [[ "$_mode_joined" == *" --release "* ]]; then
    _needs_debugger=false
  fi
  if [[ "$_needs_debugger" == true && "$FORCE_DEBUG" != true ]]; then
    local_dev="$(resolve_run_device_id || true)"
    if [[ -n "$local_dev" ]] && "$FLUTTER" devices 2>/dev/null | grep -F "$local_dev" | grep -q '(wireless)'; then
      echo "→ 检测到无线真机：自动改用 --release（profile/debug 仍会挂 LLDB 冻屏）" >&2
      echo "  需要热重载请插 USB 后加 --force-debug；已卡住请跑:" >&2
      echo "  ./scripts/cleanup_ios_debug.sh -d $local_dev" >&2
      MODE_ARGS=(--release)
    fi
  fi
  run_flutter run
fi
