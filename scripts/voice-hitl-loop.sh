#!/usr/bin/env bash
# Voice pipeline HITL acceptance loop (diagnosing-bugs Phase 1).
# Symptom codes (must match VoiceCheckReport.symptomCode):
#   record_file_invalid  → toast「录音文件无效」
#   play_failed          → DarwinAudioError /「播放失败」
#   record_start_failed  →「无法开始录音」
#   ok                   → green
#
# Usage (Warp / zsh, from my_ai_project):
#   bash scripts/voice-hitl-loop.sh
#
# App must already be running on device, e.g.:
#   f run -d 00008110-000C55112101401E --release

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [Enter when done] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

printf '\n=== Voice HITL loop ===\n'
printf 'Device expected: physical iPhone (release)\n'
printf 'Look for console lines starting with [DEBUG-voice]\n'

step "确认 App 已在真机 release 跑着（f run -d <udid> --release）。解锁手机，打开任意单聊会话。"

step "点输入栏「+」→「语音自检」。等待约 2 秒（会自动录音+试播）。允许麦克风权限。"

capture SELF_TOAST "语音自检结束后，Toast 全文是什么？（原样粘贴）"

capture SELF_CODE "Toast/日志里的 symptom code 是哪个？(record_file_invalid|play_failed|record_start_failed|ok|unknown)"

capture DEBUG_LINES "从 Warp 终端里复制所有含 [DEBUG-voice] 的行（多行可粘成一行，或写 none）："

step "再试一次手势路径：切到语音模式 → 按住说话 ≥2 秒 → 松开。不要上滑取消。"

capture HOLD_TOAST "按住说话松开后的 Toast/结果？（发送成功 / 录音文件无效 / 说话时间太短 / 其它原文）"

capture HOLD_SAME "手势结果与「语音自检」是否同一类失败？(y/n/na)"

printf '\n--- Captured ---\n'
printf 'SELF_TOAST=%s\n' "$SELF_TOAST"
printf 'SELF_CODE=%s\n' "$SELF_CODE"
printf 'DEBUG_LINES=%s\n' "$DEBUG_LINES"
printf 'HOLD_TOAST=%s\n' "$HOLD_TOAST"
printf 'HOLD_SAME=%s\n' "$HOLD_SAME"

# Red-capable verdict for the agent:
case "$SELF_CODE" in
  ok)
    echo "VERDICT=green_selfcheck"
    ;;
  record_file_invalid|play_failed|record_start_failed)
    echo "VERDICT=red_selfcheck code=$SELF_CODE"
    ;;
  *)
    echo "VERDICT=red_unknown code=$SELF_CODE"
    ;;
esac
