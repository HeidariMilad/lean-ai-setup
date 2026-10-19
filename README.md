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

**Codex** (CLI, IDE extension, or Codex inside the ChatGPT desktop app):

```bash
codex plugin marketplace add HeidariMilad/lean-ai-setup
codex plugin add lean-ai-setup@lean-ai-setup
```

Then open `codex`, run `/hooks`, and trust the lean-ai-setup and ponytail hooks once. Codex asks for this one-time approval for any plugin that runs hooks.

**Or one terminal command for both:**

```bash
curl -fsSL https://raw.githubusercontent.com/HeidariMilad/lean-ai-setup/main/install.sh | bash
```

You can also give that command to Codex or Claude Code and ask it to run it.

If you pasted these rules into Claude's profile "Instructions for Claude" or ChatGPT custom instructions before, remove them there. The plugin now supplies them, and keeping both means paying for them twice.

## Auto-update

Every Claude Code or Codex session start checks whether the last update was more than 24 hours ago. If it was, the plugin pulls this repo and runs [update.sh](update.sh) in the background. That updates ponytail, codebase-memory-mcp (downloaded only when a new release exists), graphify, and this plugin, for both agents. Nothing slows down session start.

Auto-update means code from this repo and the three tools' repos runs on your machine every day. Only install it if you trust them.

## ChatGPT

Codex inside the ChatGPT desktop app is covered by the Codex install above. A plain ChatGPT chat (web or app) can't run local tools, hooks or MCP servers, so only the behavior rules carry over. Paste this into **Settings → Personalization → Custom instructions**:

```
When writing code: give the smallest complete solution. Use the standard library and the project's existing code first; add no abstractions, options or dependencies nobody asked for. Keep answers short: what changed, then what you skipped or didn't check.
```

## Requirements

macOS or Linux with `git`, `curl`, `python3`, and `node` (for ponytail's hooks). Windows isn't supported.

## Uninstall

```
/plugin uninstall lean-ai-setup@lean-ai-setup
```

In Codex: `codex plugin remove lean-ai-setup@lean-ai-setup`. Then delete `~/.lean-ai-setup`. This leaves ponytail, codebase-memory-mcp and graphify installed; remove them with their own uninstall commands.
