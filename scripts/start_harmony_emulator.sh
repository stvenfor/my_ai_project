#!/usr/bin/env bash
# 便捷入口 → start_emulator.sh harmony
exec "$(cd "$(dirname "$0")" && pwd)/start_emulator.sh" harmony "$@"
