Default: minimal, stdlib-first solution, no unrequested abstractions (ponytail full).
Don't apply ponytail to custom or detail-heavy work: high-fidelity UI, bespoke designs or flows, exact specs, intricate domain logic, or anything the user wants built out in detail. Ponytail cuts that detail, so build it fully there. Otherwise use it.
Once the user turns ponytail off in a session ("stop ponytail", "normal mode", /ponytail off, or a PONYTAIL MODE OFF notice), it stays off for the rest of that session, including after compaction: don't apply its rules or invoke the ponytail skill until they turn it on again. Every new session starts with ponytail on.

Code tools — use only when they clearly save effort:
- codebase-memory-mcp: for non-trivial structural questions (call chains, impact analysis, dead code, "who calls X"). Prefer search_graph / trace_path / get_code_snippet over many grep+read rounds. For string literals, configs, non-code files, or edits smaller than a function, use plain grep/read.
- graphify: only to understand an unfamiliar repo or document set before editing. Skip it for repos already known or tasks touching fewer than 5 files. Build a graph only when the scope clearly exceeds a glance.
- Never index or build a graph unless the task needs it.

Tool routing never overrides ponytail's "does this need to exist at all?" rule.
