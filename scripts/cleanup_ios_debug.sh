#!/usr/bin/env bash
# 清理 iOS 真机上因 Flutter/LLDB debug 中断而冻住的 Runner / debugserver。
# 症状：页面卡死、无法滑回桌面/进后台、多任务里划不掉。
#
# 用法:
#   ./scripts/cleanup_ios_debug.sh              # 自动选第一个非模拟器 iOS 设备
#   ./scripts/cleanup_ios_debug.sh -d <udid>
#   ./scripts/cleanup_ios_debug.sh --uninstall   # 额外卸载 App（最彻底）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE_ID="${IOS_BUNDLE_ID:-com.sample.moduleSample}"
DEVICE_ID=""
UNINSTALL=false

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \?//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -d) DEVICE_ID="${2:-}"; shift 2 ;;
    --uninstall) UNINSTALL=true; shift ;;
    *) echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

find_flutter() {
  if [[ -n "${FLUTTER_BIN:-}" ]]; then
    echo "$FLUTTER_BIN"
    return
  fi
  if [[ -x "$ROOT/.fvm/flutter_sdk/bin/flutter" ]]; then
    echo "$ROOT/.fvm/flutter_sdk/bin/flutter"
    return
  fi
  command -v flutter
}

pick_device() {
  local flutter_bin
  flutter_bin="$(find_flutter)"
  # Prefer lines marked (wireless) or physical ios without simulator.
  local line id
  while IFS= read -r line; do
    [[ "$line" == *"•"* ]] || continue
    [[ "$line" == *"ios"* || "$line" == *"mobile"* ]] || continue
    [[ "$line" == *"simulator"* ]] && continue
    id="$(printf '%s\n' "$line" | awk -F ' • ' '{print $2}' | awk '{print $1}')"
    if [[ -n "$id" ]]; then
      echo "$id"
      return 0
    fi
  done < <("$flutter_bin" devices 2>/dev/null || true)
  return 1
}

kill_local_lldb() {
  echo "→ 结束本机 LLDB / flutter_tools 附加…"
  # 交互式 lldb（Flutter CoreDevice 路径）；不动长期驻留的 lldb-rpc-server。
  pkill -9 -f '/Developer/usr/bin/lldb' 2>/dev/null || true
  pkill -9 -f 'flutter_tools.snapshot run' 2>/dev/null || true
  pkill -9 -f 'flutter_tools.snapshot.*run' 2>/dev/null || true
}

kill_device_debug_stack() {
  local device="$1"
  command -v xcrun >/dev/null 2>&1 || {
    echo "警告: 无 xcrun，跳过真机清理" >&2
    return 0
  }
  local tmp
  tmp="$(mktemp)"
  if ! xcrun devicectl device info processes \
      --device "$device" --timeout 12 --json-output "$tmp" >/dev/null 2>&1; then
    echo "警告: 无法列出设备进程（无线是否断开？）" >&2
    rm -f "$tmp"
    return 0
  fi

  python3 - "$tmp" "$device" <<'PY'
import json, subprocess, sys

path, device = sys.argv[1], sys.argv[2]
data = json.load(open(path))
procs = (data.get("result") or {}).get("runningProcesses") or []

targets = []
for p in procs:
    exe = str(p.get("executable") or "")
    pid = p.get("processIdentifier")
    if not pid:
        continue
    if "/Runner.app/Runner" in exe or exe.rstrip("/").endswith("/debugserver") or "/usr/libexec/debugserver" in exe:
        targets.append((int(pid), exe))

if not targets:
    print("→ 真机上无 Runner / debugserver")
    raise SystemExit(0)

for pid, exe in targets:
    print(f"→ kill pid={pid} {exe}")
    for args in (
        ["xcrun", "devicectl", "device", "process", "resume", "--device", device, "--pid", str(pid), "--timeout", "5"],
        ["xcrun", "devicectl", "device", "process", "terminate", "--device", device, "--pid", str(pid), "--kill", "--timeout", "8"],
        ["xcrun", "devicectl", "device", "process", "signal", "--device", device, "--pid", str(pid), "--signal", "SIGKILL", "--timeout", "8"],
    ):
        subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
PY
  rm -f "$tmp"
}

if [[ -z "$DEVICE_ID" ]]; then
  if ! DEVICE_ID="$(pick_device)"; then
    echo "错误: 未找到 iOS 真机。请传 -d <udid>（flutter devices）" >&2
    exit 1
  fi
fi

echo "→ device=$DEVICE_ID"
kill_local_lldb
kill_device_debug_stack "$DEVICE_ID"

if [[ "$UNINSTALL" == true ]]; then
  echo "→ uninstall $BUNDLE_ID"
  xcrun devicectl device uninstall app --device "$DEVICE_ID" "$BUNDLE_ID" --timeout 30 2>/dev/null || true
fi

echo "✓ 清理完成。请划掉多任务里的 App（若还在），再重新 ./scripts/run_app.sh --lan -d $DEVICE_ID"
