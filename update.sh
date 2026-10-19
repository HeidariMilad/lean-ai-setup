#!/bin/bash
# Installs or updates ponytail, codebase-memory-mcp and graphify for Claude Code and Codex,
# then strips the "ALWAYS use me" extras those tools add, so only rules.md does the routing.
# Safe to re-run. macOS/Linux only.
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
export PATH="$BIN:/opt/homebrew/bin:/usr/local/bin:$PATH"
have() { command -v "$1" >/dev/null 2>&1; }
log() { echo "[$(date '+%F %T')] $*"; }
log "lean-ai-setup update started"

# codebase-memory-mcp: download only when a newer release exists (the binary is large).
# --skip-config: we register the MCP server ourselves, without its hooks and "ALWAYS" instructions.
latest=$(curl -fsSL https://api.github.com/repos/DeusData/codebase-memory-mcp/releases/latest | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p')
current=$("$BIN/codebase-memory-mcp" --version 2>/dev/null | awk '{print $2}')
if [ -z "$current" ] || { [ -n "$latest" ] && [ "$latest" != "$current" ]; }; then
  log "codebase-memory-mcp ${current:-none} -> ${latest:-latest}"
  curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash -s -- --skip-config
fi

# graphify: uv is what graphify itself prefers; plain pip breaks on PEP 668 Pythons.
have uv || curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install --upgrade graphifyy -q
if have graphify; then
  have claude && graphify install --platform claude >/dev/null
  have codex && graphify install --platform codex >/dev/null
fi

if have claude; then
  for m in DietrichGebert/ponytail HeidariMilad/lean-ai-setup; do
    claude plugin marketplace add "$m" >/dev/null 2>&1
  done
  claude plugin marketplace update ponytail >/dev/null
  claude plugin marketplace update lean-ai-setup >/dev/null
  for p in ponytail@ponytail lean-ai-setup@lean-ai-setup; do
    claude plugin install "$p" >/dev/null 2>&1 || true
    claude plugin update "$p" >/dev/null
  done
  claude mcp get codebase-memory-mcp >/dev/null 2>&1 ||
    claude mcp add -s user codebase-memory-mcp "$BIN/codebase-memory-mcp"
fi

if have codex; then
  for m in DietrichGebert/ponytail HeidariMilad/lean-ai-setup; do
    codex plugin marketplace add "$m" >/dev/null 2>&1
  done
  codex plugin marketplace upgrade ponytail >/dev/null
  codex plugin marketplace upgrade lean-ai-setup >/dev/null
  for p in ponytail@ponytail lean-ai-setup@lean-ai-setup; do
    codex plugin add "$p" >/dev/null
  done
  codex mcp get codebase-memory-mcp >/dev/null 2>&1 ||
    codex mcp add codebase-memory-mcp -- "$BIN/codebase-memory-mcp"
fi

python3 - <<'PY'
import json, os, re, sys
H = os.path.expanduser("~")

def edit(path, fn):
    if not os.path.exists(path):
        return
    old = open(path).read()
    new = fn(old)
    if new != old:
        open(path, "w").write(new)
        print("updated", path)

# 1. Drop codebase-memory's "ALWAYS prefer graph tools" blocks.
cbm = lambda s: re.sub(r"\n*<!-- codebase-memory-mcp:start -->.*?<!-- codebase-memory-mcp:end -->\n?", "\n", s, flags=re.S)
for f in ("~/.claude/CLAUDE.md", "~/.codex/AGENTS.md"):
    edit(os.path.expanduser(f), cbm)

# 2. Narrow graphify's skill trigger so it doesn't fire on every code question.
desc = ('description: "Use only when the user types /graphify, or to understand an unfamiliar repo or document '
        'corpus (papers, cross-doc links) before editing it. Not for known repos, small tasks touching <5 files, '
        'or structural code questions (use codebase-memory-mcp). Turns any input (code, docs, papers, images, '
        'videos) into a persistent knowledge graph with query/path/explain tools."')
for d in (".claude/skills", ".codex/skills", ".agents/skills"):
    edit(f"{H}/{d}/graphify/SKILL.md", lambda s: re.sub(r"^description: .*$", lambda _: desc, s, count=1, flags=re.M))

# 3. Remove codebase-memory's session-start reminder and Grep/Glob gate hooks from Claude settings.
p = f"{H}/.claude/settings.json"
if os.path.exists(p):
    cfg = json.load(open(p))
    before = json.dumps(cfg)
    hooks = cfg.get("hooks", {})
    for ev in list(hooks):
        hooks[ev] = [g for g in hooks[ev] if not any("cbm-" in h.get("command", "") for h in g.get("hooks", []))]
        if not hooks[ev]:
            del hooks[ev]
    if "hooks" in cfg and not hooks:
        del cfg["hooks"]
    if json.dumps(cfg) != before:  # only rewrite when a hook was removed, to keep the user's formatting
        open(p, "w").write(json.dumps(cfg, indent=2) + "\n")
        print("updated", p)
PY
log "lean-ai-setup update finished"
