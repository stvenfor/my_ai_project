#!/usr/bin/env bash
# 在业务模块目录独立运行：./scripts/run_module.sh auth [device]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULE="${1:-}"

if [[ -z "$MODULE" ]]; then
  echo "用法: $0 <模块名> [flutter run 额外参数...]"
  echo "示例: $0 auth"
  echo "      $0 home -d chrome"
  echo "可用: auth, home, settings(mine), chat, community"
  exit 1
fi

shift || true

case "$MODULE" in
  auth) DIR="module_auth" ;;
  home) DIR="module_home" ;;
  mine|settings) DIR="module_settings" ;;
  chat) DIR="module_chat" ;;
  community) DIR="module_community" ;;
  *)
    echo "未知模块: $MODULE"
    exit 1
    ;;
esac

cd "$ROOT/$DIR"
flutter pub get
exec flutter run -t lib/main_dev.dart "$@"
