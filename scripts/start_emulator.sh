#!/usr/bin/env bash
# 启动 Android / iOS / HarmonyOS 模拟器
# 用法见: ./scripts/start_emulator.sh --help
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLATFORM=""
NAME=""
LIST_ONLY=false
WAIT=false

usage() {
  cat <<'EOF'
用法:
  ./scripts/start_emulator.sh <platform> [名称] [选项]

平台:
  android | and | avd     Android Emulator (AVD)
  ios | iphone | sim      iOS Simulator
  harmony | ohos | hos    HarmonyOS Emulator (DevEco)

选项:
  -l, --list              列出可用模拟器，不启动
  -w, --wait              启动后等到设备就绪（adb / simctl / hdc）
  -h, --help              显示帮助

环境变量（可选默认机型）:
  ANDROID_AVD             如 Pixel_7_Pro
  IOS_SIMULATOR           如 "iPhone 17 Pro"
  HARMONY_EMULATOR        如 "Pura 90"
  ANDROID_HOME            Android SDK 根目录
  DEVECO_EMULATOR         DevEco Emulator 可执行文件路径

示例:
  ./scripts/start_emulator.sh android
  ./scripts/start_emulator.sh android Pixel_7_Pro --wait
  ./scripts/start_emulator.sh ios
  ./scripts/start_emulator.sh ios "iPhone 17 Pro"
  ./scripts/start_emulator.sh harmony --list
  ./scripts/start_emulator.sh harmony "Pura 90"
EOF
}

log() { printf '%s\n' "$*"; }
err() { printf '错误: %s\n' "$*" >&2; }

resolve_android_sdk() {
  if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
    echo "$ANDROID_HOME"
    return
  fi
  if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "$ANDROID_SDK_ROOT" ]]; then
    echo "$ANDROID_SDK_ROOT"
    return
  fi
  local candidate="$HOME/Library/Android/sdk"
  if [[ -d "$candidate" ]]; then
    echo "$candidate"
    return
  fi
  return 1
}

resolve_android_emulator() {
  local sdk
  sdk="$(resolve_android_sdk)" || return 1
  local bin="$sdk/emulator/emulator"
  [[ -x "$bin" ]] || return 1
  echo "$bin"
}

resolve_adb() {
  local sdk
  if sdk="$(resolve_android_sdk 2>/dev/null)"; then
    if [[ -x "$sdk/platform-tools/adb" ]]; then
      echo "$sdk/platform-tools/adb"
      return
    fi
  fi
  command -v adb
}

list_android_avds() {
  local emu
  emu="$(resolve_android_emulator)" || {
    err "未找到 Android emulator。请安装 Android Studio / SDK，或设置 ANDROID_HOME。"
    exit 1
  }
  "$emu" -list-avds
}

pick_android_avd() {
  local wanted="${1:-${ANDROID_AVD:-}}"
  local -a avds=()
  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] && avds+=("$line")
  done < <(list_android_avds)

  if ((${#avds[@]} == 0)); then
    err "没有可用的 AVD。请先在 Android Studio → Device Manager 创建模拟器。"
    exit 1
  fi

  if [[ -n "$wanted" ]]; then
    local a
    for a in "${avds[@]}"; do
      if [[ "$a" == "$wanted" ]]; then
        echo "$a"
        return
      fi
    done
    err "未找到 AVD: $wanted"
    log "可用:"
    printf '  %s\n' "${avds[@]}"
    exit 1
  fi

  echo "${avds[0]}"
}

android_emulator_running() {
  local adb
  adb="$(resolve_adb)" || return 1
  "$adb" devices 2>/dev/null | awk 'NR>1 && $2=="device" && $1 ~ /^emulator-/' | grep -q .
}

wait_android() {
  local adb
  adb="$(resolve_adb)" || return 0
  log "等待 Android 模拟器就绪..."
  "$adb" wait-for-device
  local i=0
  while ((i < 120)); do
    if [[ "$("$adb" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
      log "Android 模拟器已就绪。"
      return
    fi
    sleep 2
    i=$((i + 2))
  done
  err "等待 Android boot_completed 超时。"
  exit 1
}

start_android() {
  if [[ "$LIST_ONLY" == true ]]; then
    list_android_avds
    return
  fi

  local emu avd
  emu="$(resolve_android_emulator)" || {
    err "未找到 Android emulator。请安装 Android Studio / SDK，或设置 ANDROID_HOME。"
    exit 1
  }
  avd="$(pick_android_avd "$NAME")"

  if android_emulator_running; then
    log "已有 Android 模拟器在运行，跳过启动（目标 AVD: ${avd}）。"
    if [[ "$WAIT" == true ]]; then
      wait_android
    fi
    return
  fi

  log "启动 Android AVD: $avd"
  # 后台启动；不占用当前终端
  nohup "$emu" -avd "$avd" -netdelay none -netspeed full >/tmp/android-emulator-"$avd".log 2>&1 &
  disown || true
  log "已后台启动（日志: /tmp/android-emulator-$avd.log）。"
  if [[ "$WAIT" == true ]]; then
    wait_android
  fi
}

list_ios_sims() {
  xcrun simctl list devices available | sed -n '/^== Devices ==/,$p'
}

ios_booted_udid() {
  # 行格式: "    iPhone 17 Pro (UUID) (Booted) "
  xcrun simctl list devices available \
    | sed -n 's/.*(\([0-9A-Fa-f-]\{36\}\)) (Booted).*/\1/p' \
    | head -1
}

pick_ios_simulator() {
  local wanted="${1:-${IOS_SIMULATOR:-}}"
  local line name udid

  parse_line() {
    # "    iPhone 17 Pro (UUID) (Shutdown) "
    line="$1"
    if [[ "$line" =~ ^[[:space:]]*(.+)[[:space:]]\(([0-9A-Fa-f-]{36})\)[[:space:]]\((Shutdown|Booted|Creating)\) ]]; then
      name="${BASH_REMATCH[1]}"
      name="${name%"${name##*[![:space:]]}"}"
      udid="${BASH_REMATCH[2]}"
      return 0
    fi
    return 1
  }

  if [[ -n "$wanted" ]]; then
    if [[ "$wanted" =~ ^[0-9A-Fa-f-]{36}$ ]]; then
      echo "$wanted"
      return
    fi
    while IFS= read -r line; do
      if parse_line "$line" && [[ "$name" == "$wanted" ]]; then
        echo "$udid|$name"
        return
      fi
    done < <(xcrun simctl list devices available)
    err "未找到 iOS 模拟器: $wanted"
    exit 1
  fi

  local booted
  booted="$(ios_booted_udid || true)"
  if [[ -n "$booted" ]]; then
    echo "$booted|"
    return
  fi

  local prefer
  # 优先 iOS 18 系机型（与多数插件/引擎兼容面更稳）；再回退到 17 系。
  for prefer in "iPhone 16 Pro" "iPhone 16" "iPhone 17 Pro" "iPhone 17"; do
    while IFS= read -r line; do
      if parse_line "$line" && [[ "$name" == "$prefer" ]]; then
        echo "$udid|$name"
        return
      fi
    done < <(xcrun simctl list devices available)
  done

  while IFS= read -r line; do
    if parse_line "$line" && [[ "$name" == iPhone* ]]; then
      echo "$udid|$name"
      return
    fi
  done < <(xcrun simctl list devices available)

  err "没有可用的 iOS 模拟器。请在 Xcode → Settings → Platforms 安装 runtime。"
  exit 1
}

wait_ios() {
  local udid="$1"
  log "等待 iOS 模拟器就绪..."
  local i=0
  while ((i < 90)); do
    if xcrun simctl list devices | grep -F "$udid" | grep -q '(Booted)'; then
      log "iOS 模拟器已就绪。"
      return
    fi
    sleep 1
    i=$((i + 1))
  done
  err "等待 iOS Booted 超时。"
  exit 1
}

start_ios() {
  command -v xcrun >/dev/null || {
    err "未找到 xcrun。请安装 Xcode Command Line Tools。"
    exit 1
  }

  if [[ "$LIST_ONLY" == true ]]; then
    list_ios_sims
    return
  fi

  local picked udid name
  picked="$(pick_ios_simulator "$NAME")"
  udid="${picked%%|*}"
  name="${picked#*|}"

  if [[ -z "$name" ]]; then
    log "已有 iOS 模拟器在运行（${udid}），打开 Simulator 窗口。"
  else
    log "启动 iOS 模拟器: ${name} (${udid})"
  fi

  local state=""
  if xcrun simctl list devices | grep "$udid" | grep -q '(Booted)'; then
    state="Booted"
  elif xcrun simctl list devices | grep "$udid" | grep -q '(Creating)'; then
    state="Creating"
  else
    state="Shutdown"
  fi
  if [[ "$state" != "Booted" ]]; then
    xcrun simctl boot "$udid"
  fi
  open -a Simulator --args -CurrentDeviceUDID "$udid" || true
  if [[ "$WAIT" == true ]]; then
    wait_ios "$udid"
  fi
}

resolve_harmony_emulator() {
  if [[ -n "${DEVECO_EMULATOR:-}" && -x "$DEVECO_EMULATOR" ]]; then
    echo "$DEVECO_EMULATOR"
    return
  fi
  local candidates=(
    "/Applications/DevEco-Studio.app/Contents/tools/emulator/Emulator"
    "$HOME/Applications/DevEco-Studio.app/Contents/tools/emulator/Emulator"
  )
  local c
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then
      echo "$c"
      return
    fi
  done
  return 1
}

resolve_hdc() {
  if command -v hdc >/dev/null 2>&1; then
    command -v hdc
    return
  fi
  local candidates=(
    "/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc"
    "/Applications/DevEco-Studio.app/Contents/sdk/default/hms/toolchains/hdc"
  )
  local c
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then
      echo "$c"
      return
    fi
  done
  return 1
}

list_harmony_emulators() {
  local emu
  emu="$(resolve_harmony_emulator)" || {
    err "未找到 DevEco Emulator。请安装 DevEco Studio，或设置 DEVECO_EMULATOR。"
    exit 1
  }
  "$emu" -list
}

harmony_is_running() {
  local name="$1"
  local emu details
  emu="$(resolve_harmony_emulator)" || return 1
  details="$("$emu" -list -details 2>/dev/null || true)"
  printf '%s' "$details" | grep -A2 -F "\"name\": \"$name\"" | grep -q '"isRunning": "true"'
}

pick_harmony_emulator() {
  local wanted="${1:-${HARMONY_EMULATOR:-}}"
  local -a names=()
  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] && names+=("$line")
  done < <(list_harmony_emulators)

  if ((${#names[@]} == 0)); then
    err "没有 HarmonyOS 模拟器实例。请先在 DevEco Studio → Device Manager 创建。"
    exit 1
  fi

  if [[ -n "$wanted" ]]; then
    local n
    for n in "${names[@]}"; do
      if [[ "$n" == "$wanted" ]]; then
        echo "$n"
        return
      fi
    done
    err "未找到 HarmonyOS 模拟器: $wanted"
    log "可用:"
    printf '  %s\n' "${names[@]}"
    exit 1
  fi

  local prefer
  for prefer in "Pura 90" "Pura X Max" "Mate X7" "MatePad Pro 13"; do
    for n in "${names[@]}"; do
      if [[ "$n" == "$prefer" ]]; then
        echo "$n"
        return
      fi
    done
  done
  echo "${names[0]}"
}

wait_harmony() {
  local hdc
  if ! hdc="$(resolve_hdc)"; then
    log "未找到 hdc，跳过等待设备。"
    return
  fi
  log "等待 HarmonyOS 模拟器 hdc 就绪..."
  local i=0
  while ((i < 180)); do
    if "$hdc" list targets 2>/dev/null | grep -vqE '^\s*$|Empty|\[Empty\]'; then
      log "HarmonyOS 设备已出现在 hdc list targets。"
      "$hdc" list targets 2>/dev/null || true
      return
    fi
    sleep 2
    i=$((i + 2))
  done
  err "等待 hdc 设备超时。"
  exit 1
}

start_harmony() {
  local emu name
  emu="$(resolve_harmony_emulator)" || {
    err "未找到 DevEco Emulator。请安装 DevEco Studio，或设置 DEVECO_EMULATOR。"
    exit 1
  }

  if [[ "$LIST_ONLY" == true ]]; then
    list_harmony_emulators
    return
  fi

  name="$(pick_harmony_emulator "$NAME")"

  if harmony_is_running "$name"; then
    log "HarmonyOS 模拟器已在运行: $name"
    if [[ "$WAIT" == true ]]; then
      wait_harmony
    fi
    return
  fi

  log "启动 HarmonyOS 模拟器: $name"
  # DevEco Emulator 会拉起 GUI；后台执行避免卡住脚本
  nohup "$emu" -start "$name" >/tmp/harmony-emulator.log 2>&1 &
  disown || true
  log "已后台启动（日志: /tmp/harmony-emulator.log）。"
  if [[ "$WAIT" == true ]]; then
    wait_harmony
  fi
}

# ---- parse args ----
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -l|--list)
      LIST_ONLY=true
      shift
      ;;
    -w|--wait)
      WAIT=true
      shift
      ;;
    -*)
      err "未知选项: $1"
      usage
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if ((${#POSITIONAL[@]} == 0)); then
  usage
  exit 1
fi

PLATFORM="${POSITIONAL[0]}"
NAME="${POSITIONAL[1]:-}"

case "$PLATFORM" in
  android|and|avd)
    start_android
    ;;
  ios|iphone|sim|simulator)
    start_ios
    ;;
  harmony|ohos|hos|hmos)
    start_harmony
    ;;
  *)
    err "未知平台: $PLATFORM"
    usage
    exit 1
    ;;
esac
