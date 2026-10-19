#!/bin/bash
# One-time setup for Claude Code and/or Codex: clones this repo to ~/.lean-ai-setup/repo and runs the updater.
set -e
STATE="$HOME/.lean-ai-setup"
REPO="$STATE/repo"
mkdir -p "$STATE"
if [ -d "$REPO/.git" ]; then git -C "$REPO" pull -q --ff-only
else git clone -q https://github.com/HeidariMilad/lean-ai-setup.git "$REPO"; fi
touch "$STATE/last-update"
bash "$REPO/update.sh"
