#!/usr/bin/env bash
# 在业务模块目录独立运行：./scripts/run_module.sh auth [flutter run 额外参数...]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULE="${1:-}"
ENV_FILE="$ROOT/.env"

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
如果要联调真实登录，请保持 USE_MOCK_AUTH=false 并启动 my_go_study 后端。
EOF
  exit 1
}

if [[ -z "$MODULE" ]]; then
  echo "用法: $0 <模块名> [flutter run 额外参数...]"
  echo "示例: $0 auth"
  echo "      $0 home -d chrome"
  echo "可用: auth, home, settings(mine), chat, community"
  exit 1
fi

shift || true

case "$MODULE" in
  auth) DIR="packages/features/auth" ;;
  home) DIR="packages/features/home" ;;
  mine|settings) DIR="packages/features/settings" ;;
  chat) DIR="packages/features/chat" ;;
  community) DIR="packages/features/community" ;;
  *)
    echo "未知模块: $MODULE"
    exit 1
    ;;
esac

cd "$ROOT/$DIR"
ensure_env_file
prepare_android_env
FLUTTER="$(find_flutter)"
"$FLUTTER" pub get
exec "$FLUTTER" run -t lib/main_dev.dart --dart-define-from-file="$ENV_FILE" "$@"
