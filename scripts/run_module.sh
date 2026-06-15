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
flutter pub get
exec flutter run -t lib/main_dev.dart "$@"
