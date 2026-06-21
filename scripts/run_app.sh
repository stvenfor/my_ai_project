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

usage() {
  cat <<'EOF'
用法:
  ./scripts/run_app.sh [选项] [flutter run/build 额外参数...]

运行（默认 debug）:
  ./scripts/run_app.sh
  ./scripts/run_app.sh -d <device_id>
  ./scripts/run_app.sh -r
  ./scripts/run_app.sh --release -d iPhone

Release / Profile 模式:
  -r, --release    flutter run --release（或 build 时显式 release）
  -p, --profile    flutter run --profile

构建产物（release 默认）:
  -b, --build TARGET
      android | apk      → flutter build apk
      appbundle | aab    → flutter build appbundle
      ios                → flutter build ios（需 Xcode 签名）
      ipa                → flutter build ipa

示例:
  ./scripts/run_app.sh -r -d 00008110-xxxxxxxx
  ./scripts/run_app.sh --build apk
  ./scripts/run_app.sh --build ios --release --no-codesign
  ./scripts/run_app.sh --build appbundle -r

说明:
  始终注入 --dart-define-from-file=.env。
  首次运行请先执行: cp .env.example .env
EOF
}

find_flutter() {
  if [[ -n "${FLUTTER_BIN:-}" ]]; then
    echo "$FLUTTER_BIN"
  elif [[ -x "$ROOT/.fvm/flutter_sdk/bin/flutter" ]]; then
    echo "$ROOT/.fvm/flutter_sdk/bin/flutter"
  elif [[ -x "/Users/stvenfor/fvm/default/bin/flutter" ]]; then
    echo "/Users/stvenfor/fvm/default/bin/flutter"
  else
    command -v flutter
  fi
}

prepare_android_env() {
  if [[ -d "/Users/stvenfor/Library/Android/sdk" ]]; then
    export ANDROID_HOME="${ANDROID_HOME:-/Users/stvenfor/Library/Android/sdk}"
    export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/Users/stvenfor/Library/Android/sdk}"
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
  cat >&2 <<EOF
错误: 未找到 $ENV_FILE

请先创建本地配置:
  cp .env.example .env

如果只是本地跑 Mock 登录，可将 .env 中 USE_MOCK_AUTH 改为 true。
如果要连接 Supabase，请填入真实 SUPABASE_URL / SUPABASE_ANON_KEY。
EOF
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
    -b|--build)
      BUILD=true
      BUILD_TARGET="${2:-}"
      if [[ -z "$BUILD_TARGET" ]]; then
        echo "错误: --build 需要指定目标 (apk|android|appbundle|aab|ios|ipa)" >&2
        exit 1
      fi
      shift 2
      ;;
    build)
      BUILD=true
      BUILD_TARGET="${2:-}"
      if [[ -z "$BUILD_TARGET" ]]; then
        echo "错误: build 需要指定目标 (apk|android|appbundle|aab|ios|ipa)" >&2
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

ensure_env_file
prepare_android_env
FLUTTER="$(find_flutter)"
ENV_ARGS=(--dart-define-from-file="$ENV_FILE")

"$FLUTTER" pub get

# bash 3.2 + set -u 下空数组 "${arr[@]}" 会报 unbound variable，需先判长度。
run_flutter() {
  local -a cmd=("$FLUTTER" "$@")
  if ((${#ENV_ARGS[@]} > 0)); then cmd+=("${ENV_ARGS[@]}"); fi
  if ((${#MODE_ARGS[@]} > 0)); then cmd+=("${MODE_ARGS[@]}"); fi
  if ((${#EXTRA_ARGS[@]} > 0)); then cmd+=("${EXTRA_ARGS[@]}"); fi
  exec "${cmd[@]}"
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
    *)
      echo "未知构建目标: $BUILD_TARGET" >&2
      echo "支持: apk, android, appbundle, aab, ios, ipa" >&2
      exit 1
      ;;
  esac
else
  run_flutter run
fi
