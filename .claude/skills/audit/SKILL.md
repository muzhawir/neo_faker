---
name: audit
description: Audit Elixir code for official anti-patterns (code, design, process, macro) documented by the Elixir team, and report concrete findings with file/line references and suggested refactors.
---

# Elixir anti-pattern audit

> Reference: https://elixir.hexdocs.pm/1.20.4/what-anti-patterns.md

This skill audits Elixir source for the anti-patterns catalogued in the
official Elixir documentation. Per that documentation, anti-patterns are
"common mistakes or indicators of problems in code" (a.k.a. code smells).
Keep the docs' own caveat in mind while auditing: **matching an anti-pattern
does not automatically mean the code must change.** Sometimes a snippet that
matches an anti-pattern's shape is still the best available solution to the
problem at hand. No codebase is free of anti-patterns, and removing every
last one is not the goal — flag matches, explain the trade-off, and let the
reader (or the calling agent) judge whether a fix is worth it here.

The catalogue has four categories, each with its own detailed rules file in
`rules/`:

| Category | Concerns | Rules file |
|---|---|---|
| Code-related | Language idioms/constructs visible in a single function or module | `rules/code-anti-patterns.md` |
| Design-related | Module/function API design, options, return types | `rules/design-anti-patterns.md` |
| Process-related | `GenServer`/`Agent`/`Task`/`spawn` usage and supervision | `rules/process-anti-patterns.md` |
| Macro-related | `defmacro`/`quote`/`unquote`/`use` meta-programming | `rules/macro-anti-patterns.md` |

Each rules file documents, per anti-pattern: the **Problem** (why it's
harmful, quoted from the docs), an **Anti-pattern** code example, the
**Refactored** code, any **Additional remarks** (documented exceptions/nuance),
and a **Detection heuristics** list you can pattern-match against while
reading code — that last section is not part of the official docs; it's a
practical checklist added here to make each anti-pattern actionable during
review.

## How to run this audit

1. **Determine the scope.** By default, audit the current diff (staged +
   unstaged changes vs. the base branch) if the user is mid-change; audit an
   explicit path/file/module if one is named; audit the whole `lib/` tree
   (skip `deps/`, `_build/`, generated code) if the user asks for a full
   sweep. Confirm scope with the user only if it's genuinely ambiguous.

2. **Load the relevant rules files.** For a full audit, read all four files
   in `rules/`. If the scope is narrow and obviously limited to one category
   (e.g. only `defmacro`/`use` code, or only `GenServer` modules), it's fine
   to load just the matching rules file(s) — but when in doubt, load all
   four; categories are not mutually exclusive (e.g. a `GenServer` module can
   simultaneously exhibit a code-related and a process-related issue).

3. **Read the target code in full** before judging it — don't pattern-match
   on isolated snippets out of context. Many anti-patterns (e.g. "Unrelated
   multi-clause function", "Scattered process interfaces") only become
   visible when you see how a function/process is used across multiple call
   sites or clauses.

4. **Check each anti-pattern's "Detection heuristics"** against the code.
   For every match, verify it against the anti-pattern's actual "Problem"
   description before reporting it — the heuristic is a starting point for
   suspicion, not a verdict.

5. **Filter out matches that are the documented exceptions.** Each rules
   file's "Additional remarks" section lists cases the Elixir team explicitly
   carves out (e.g. raising on invalid arguments is fine; `use` is fine when
   it truly needs macro-level injection and is documented; application
   config is fine for the top-level *application*, not for *libraries*).
   Don't flag those.

6. **Report findings**, grouped by category, each with:
   - File path and line number(s).
   - Which anti-pattern it matches (name + category).
   - A one-sentence explanation of why it applies *here* (not just a restatement
     of the generic problem).
   - A concrete suggested refactor, adapted to the actual code (not just the
     generic example from the rules file).
   - Severity/confidence: call out anything that's a plausible false positive
     or a case where leaving it as-is may be the right call (per the "no
     codebase is free of anti-patterns" caveat above).

   If no instances of a category are found, say so briefly rather than
   omitting the category — that's useful signal that the check ran.

7. **Do not auto-fix by default.** Report findings first. Only apply fixes
   if the user asks for it (or an equivalent explicit flag/instruction), and
   when fixing, re-run the same checklist against the result to confirm the
   refactor didn't introduce a different anti-pattern from the same catalogue
   (e.g. splitting a long parameter list into a map, but then growing that
   map's backing struct past 32 fields).

## Scope notes specific to this project

This is a library (`neo_faker`), not an application, so the
"Using application configuration for libraries" and "Using Application
configuration" guidance in `rules/design-anti-patterns.md` applies with full
force to any new public API: don't have `lib/neo_faker/**` modules read
`Application.get_env/2` for anything other than the documented `:locale`
mechanism already centralized in `NeoFaker.Data`/`NeoFaker` — new features
should take configuration as function arguments/options instead.
