#!/bin/bash
# Claude Code + Codex: adds the routing rules to the session, then refreshes all tools in the background at most once a day.
# On compaction in Claude Code it also says whether ponytail is still off, since the summary may drop that.
HOOK_INPUT="$(cat)" python3 - "$(dirname "$0")/../rules.md" <<'PY'
import hashlib, json, os, sys
rules = open(sys.argv[1]).read()
try:
    source = json.loads(os.environ.get("HOOK_INPUT") or "{}").get("source")
except Exception:
    source = None
project = os.environ.get("CLAUDE_PROJECT_DIR", "").strip()
# Codex sets PLUGIN_DATA and keeps ponytail's mode elsewhere, so only Claude Code is checked.
if source == "compact" and project and not os.environ.get("PLUGIN_DATA"):
    # Same per-project flag ponytail's own hooks write; a missing flag means off.
    modes = os.path.join(os.environ.get("CLAUDE_CONFIG_DIR") or os.path.expanduser("~/.claude"), "ponytail-modes")
    flag = os.path.join(modes, hashlib.sha256(os.path.normpath(project).encode()).hexdigest())
    try:
        mode = open(flag).read().strip()
    except OSError:
        mode = "off"
    if os.path.isdir(modes) and mode in ("", "off"):
        rules += "\nPONYTAIL IS OFF in this session (the user turned it off before compaction). Keep it off.\n"
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": rules}}))
PY

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
