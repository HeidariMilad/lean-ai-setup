# lean-ai-setup

One install that sets up a lean, token-saving coding-agent setup for **Claude Code** and **Codex**, and keeps it updated:

- [ponytail](https://github.com/DietrichGebert/ponytail): smallest-change, short-answer mode
- [codebase-memory-mcp](https://github.com/DeusData/codebase-memory-mcp): live structural index of your code (who calls what)
- [graphify](https://github.com/Graphify-Labs/graphify) (`graphifyy` on PyPI): knowledge graph for repos or docs you don't know yet

It also writes short routing rules ([rules.md](rules.md)) so the agent uses these tools only when they save tokens. It removes the "ALWAYS use me" hooks and instruction blocks the tools add themselves, because those make every session cost more.

## Install

**Claude Code** (also sets up Codex if it's installed):

```
/plugin marketplace add HeidariMilad/lean-ai-setup
/plugin install lean-ai-setup@lean-ai-setup
```

Start a new session. The first session installs everything in the background (log: `~/.lean-ai-setup/update.log`), and the setup is complete from the session after that.

**Terminal (Claude Code and/or Codex, no plugin step needed):**

```bash
curl -fsSL https://raw.githubusercontent.com/HeidariMilad/lean-ai-setup/main/install.sh | bash
```

For Codex, open `codex`, run `/hooks`, and trust ponytail's two hooks once.

If you pasted these rules into Claude's profile "Instructions for Claude" or ChatGPT custom instructions before, remove them there. The plugin now supplies them, and keeping both means paying for them twice.

## Auto-update

Every Claude Code session start checks whether the last update was more than 24 hours ago. If it was, the plugin pulls this repo and runs [update.sh](update.sh) in the background. That updates ponytail, codebase-memory-mcp (downloaded only when a new release exists), graphify, this plugin, and the Codex rules. Nothing slows down session start.

If you only use Codex, there's no session hook, so re-run the install command now and then, or add a daily cron job:

```bash
(crontab -l 2>/dev/null; echo '0 10 * * * bash ~/.lean-ai-setup/repo/update.sh >> ~/.lean-ai-setup/update.log 2>&1') | crontab -
```

Auto-update means code from this repo and the three tools' repos runs on your machine every day. Only install it if you trust them.

## ChatGPT (web/desktop app)

ChatGPT can't run local tools, hooks or MCP servers, so only the behavior rules carry over. Paste this into **Settings → Personalization → Custom instructions**:

```
When writing code: give the smallest complete solution. Use the standard library and the project's existing code first; add no abstractions, options or dependencies nobody asked for. Keep answers short: what changed, then what you skipped or didn't check.
```

## Requirements

macOS or Linux with `git`, `curl`, `python3`, and `node` (for ponytail's hooks). Windows isn't supported.

## Uninstall

```
/plugin uninstall lean-ai-setup@lean-ai-setup
```

Then delete `~/.lean-ai-setup` and remove the `lean-ai-setup` block from `~/.codex/AGENTS.md`. This leaves ponytail, codebase-memory-mcp and graphify installed; remove them with their own uninstall commands.
