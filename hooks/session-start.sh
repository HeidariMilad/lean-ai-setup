#!/bin/bash
# Claude Code + Codex: adds the routing rules to the session, then refreshes all tools in the background at most once a day.
python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": open(sys.argv[1]).read()}}))' \
  "$(dirname "$0")/../rules.md"

STATE="$HOME/.lean-ai-setup"
[ -n "$(find "$STATE/last-update" -mmin -1440 2>/dev/null)" ] && exit 0
mkdir -p "$STATE" && touch "$STATE/last-update"
(
  REPO="$STATE/repo"
  if [ -d "$REPO/.git" ]; then git -C "$REPO" pull -q --ff-only
  else git clone -q https://github.com/HeidariMilad/lean-ai-setup.git "$REPO"; fi
  bash "$REPO/update.sh"
) </dev/null >>"$STATE/update.log" 2>&1 &
exit 0
