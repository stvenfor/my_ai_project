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
  始终注入 --dart-define-from-file=.env（若文件存在）。
EOF
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

ENV_ARGS=()
if [[ -f "$ROOT/.env" ]]; then
  ENV_ARGS+=(--dart-define-from-file=.env)
else
  echo "提示: 未找到 .env，跳过 --dart-define-from-file" >&2
fi

flutter pub get

# bash 3.2 + set -u 下空数组 "${arr[@]}" 会报 unbound variable，需先判长度。
run_flutter() {
  local -a cmd=(flutter "$@")
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
