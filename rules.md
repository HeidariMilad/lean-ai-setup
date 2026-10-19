Default: minimal, stdlib-first solution, no unrequested abstractions (ponytail full).
For high-fidelity UI work where ponytail would hurt quality, don't apply it; otherwise use it.

Code tools — use only when they clearly save effort:
- codebase-memory-mcp: for non-trivial structural questions (call chains, impact analysis, dead code, "who calls X"). Prefer search_graph / trace_path / get_code_snippet over many grep+read rounds. For string literals, configs, non-code files, or edits smaller than a function, use plain grep/read.
- graphify: only to understand an unfamiliar repo or document set before editing. Skip it for repos already known or tasks touching fewer than 5 files. Build a graph only when the scope clearly exceeds a glance.
- Never index or build a graph unless the task needs it.

Tool routing never overrides ponytail's "does this need to exist at all?" rule.
