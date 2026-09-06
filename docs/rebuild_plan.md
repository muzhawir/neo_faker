# NeoFaker Rebuild Plan

Status: **approved — §8 decisions locked, execution in progress (see §9 for phase status)**
Scope: full rewrite of `lib/neo_faker/**`, backend and public API. Breaking changes are
accepted (pre-1.0, current `~> 0.14`); old versions will be flagged outdated on Hex once this
ships. Target version: **0.15.0**.

## 1. Why

The codebase was written while learning Elixir. It works and is well tested (325 tests, `mix
credo --strict` clean), but the internal architecture accreted ad hoc per-domain rather than
following one rule, and a few backend mechanisms rely on process-wide mutable state that fights
Elixir's own concurrency model. Two things prompted this:

- Backend audit (state management, RNG): see [§4.1](#41-backend-state-management).
- Module-organization audit (submodule conventions across domains): see [§4.2](#42-module-organization).
- A pass over public-facing modules turned up API-level convention issues too: see
  [§4.3](#43-public-api-conventions).

## 2. Guiding principles

**Domain-Driven Design, translated to what actually applies to a stateless generator library.**
NeoFaker has no aggregates, no persistence, no business invariants to protect — most of DDD's
tactical patterns don't apply. What *does* transfer, and what this plan uses as vocabulary:

- **Bounded context** = one domain module (`NeoFaker.Address`, `NeoFaker.Person`, ...). Each
  owns its own vocabulary, data files, and generation rules. A context's internals are private;
  other contexts may only call its public functions (already true today — e.g.
  `NeoFaker.Internet` calling `NeoFaker.Text.word/0` — and this plan keeps it that way).
- **Ubiquitous language** = the public function/option names must match the domain's real
  vocabulary (`NeoFaker.Address.building_number/2`, not `NeoFaker.Address.number/2`) — already
  mostly true, called out only where it isn't.
- **Shared kernel** = `NeoFaker.Data`, locale resolution, RNG, and `NeoFaker.Helpers.*`. Every
  context depends on this layer; it must be small, boring, and side-effect-free — this is
  exactly what's currently *not* true (see §4.1) and the highest-priority fix.

**Official Elixir convention, concretely:**

- One private-submodule naming rule, applied without exception, not invented per domain.
- `alias` + explicit call for every intra-package reference; no bare `import` of project
  modules (stdlib macros like `import Bitwise` would be fine — none are currently needed).
- `keyword()` for keyword-list typespecs, not `Keyword.t()` — pick one, per the [Typespecs
  guide](https://elixir.hexdocs.pm/1.20.4/typespecs.md), and it should be the builtin.
- A function returns one shape for one meaning. Where a function's return shape genuinely
  varies with an explicit option (`Color.random/1` picking a random *format*), that's
  documented as intentional, not left ambiguous.
- Lower-case, snake_case file names throughout `lib/` — no exceptions for acronyms.

## 3. What is out of scope

- `NeoFaker.Number`, `NeoFaker.Boolean`, `NeoFaker.Gravatar`, `NeoFaker.Crypto` internals
  already match the target shape (`Generator` + `Validator`, `alias`-only, no global state) —
  they're touched only for the mechanical renames in §5.3, not redesigned.
- Locale *data* (`priv/data/**/*.exs`) is not restructured — this plan is code architecture,
  not content.
- No new domains/generators are added as part of this plan.
- `NeoFaker.Sequence` / Faker-style `.unique` — already discussed and declined earlier; not
  part of this rebuild.

## 4. Current-state audit (summary)

### 4.1 Backend state management

- `NeoFaker.set_locale/1` writes to `Application.put_env(:neo_faker, :locale, ...)` — a
  **node-global**, not process-scoped, mutable value — and every generator call falls back to
  reading it via `NeoFaker.Data.resolve_locale_config/1` when no `locale:` option is given.
  `test/neo_faker_test.exs` is already hard-coded to `async: false` because it calls
  `set_locale/1`, while every other test file runs `async: true` — the codebase has already
  paid the cost of this design once and worked around it locally instead of fixing it.
- `NeoFaker.Data.put_cache!/3` calls `:rand.seed(:exsplus, :os.timestamp())` as a side effect
  the first time any `(locale, module, file)` triple is read. This silently overrides any seed
  a caller set themselves (e.g. for deterministic test snapshots), and there is no
  functional reason for it — OTP already auto-seeds `:rand` per process.
- `NeoFaker.locale/0` mixes a `{:ok, _} | :error` contract with an unguarded `raise
  ArgumentError` for a corrupt config value. This path is real, not dead code — it's exactly
  what happens if someone follows `getting-started.md`'s own Phoenix instructions
  (`config :neo_faker, locale: :bogus` in `config/dev.exs`) — but the function's typespec and
  docs don't say it can raise.

### 4.2 Module organization

No single convention for "where does a domain's generation logic live." At least five
different shapes exist side by side:

| Domain | What it actually does |
|---|---|
| `date`, `number`, `gravatar` | `Generator` + `Validator` (the documented pattern) |
| `color` | One file per output format (`cmyk.ex`, `hex.ex`, `hsl.ex`, ...) + `Validator`, no `Generator` |
| `internet` | Generic `Generator` (IP/MAC/URL) **and** feature-named `Domain`/`Email`/`TLD`/`Username` — no rule for which bucket a function goes in |
| `HTTP` | `Header`/`StatusCode`/`UserAgent` (feature-named) + `Validator`, no `Generator` |
| `text` | Generic `Generator` **and** a separate `EmojiGenerator` |
| `lorem` | `Parser` only |
| `person` | `NameGenerator` + `FullNameGenerator`, no generic `Generator` |
| `blood` | No submodule at all — inline in `blood.ex` |
| `crypto` | `Hash` (feature-named) |
| `app` | `Domain`/`Name`/`Semver` (feature-named), and `app.ex` uses bare `import` for `Name`/`Semver` while every other domain uses `alias` |
| `en_us`/`id_id` person | `Utils` — yet another name |

All of these submodules are `@moduledoc false` (never part of the public docs), so
standardizing them is an internal reorganization, not a breaking change to consumers.

Also: `lib/neo_faker/HTTP.ex` and `lib/neo_faker/HTTP/*.ex` are the only upper-case
file/directory names in the tree.

### 4.3 Public API conventions

- `Keyword.t()` and `keyword()` are both used for the same kind of `opts` parameter across
  different files (e.g. `address.ex`/`date.ex`/`person.ex` use `Keyword.t()`; `color.ex`
  uses `keyword()`) — no consistent choice.
- The `NeoFaker.Helpers.Options`/`Formatter` modules re-implement, by hand, exactly what
  [`NimbleOptions`](https://hexdocs.pm/nimble_options) exists for: schema-declared options,
  defaults, allowed values, and auto-generated error messages. The current approach means
  every domain function repeats a 3–6 line `Options.get/3` + `Validator.validate_x!/1` dance —
  around 90 call sites across the package for the same handful of validation shapes (enum
  membership, numeric range, boolean flag).
- `NeoFaker.Color.random/1` can return a tuple *or* a string depending on which format is
  randomly picked — this is an intentional "random format" contract, but it's currently
  undocumented as such and reads like the "alternative return type" anti-pattern on a casual
  pass. Needs an explicit note (or a `format:` option to force one shape) rather than a
  behavior change.
- Locale-exclusive modules live at the top level — `NeoFaker.EnUs.Person`,
  `NeoFaker.IdId.Person` — and are distinguished from regular domain modules only by a regex in
  `mix.exs` (`~r/^NeoFaker\.[A-Z][a-z][A-Z][a-z]\..+/`) that depends on locale codes always
  being exactly two 2-letter-capitalized segments. It works today by coincidence of which
  locales exist, not by design, and breaks the moment a 3-segment locale code (e.g. a
  hypothetical `pt_br` vs `zh_hans`) is added.

## 5. Target architecture

### 5.1 Bounded contexts — unchanged, reinforced

`NeoFaker.<Domain>` stays the only public entry point per domain. Rule made explicit (and
checked by the `audit` skill going forward): a context module may call another context's
public functions, never its private submodules.

### 5.2 Shared kernel

`NeoFaker.Data`, locale resolution, RNG concerns, and `NeoFaker.Helpers.*` — redesigned per
§6. Every context depends only on this layer for cross-cutting concerns.

### 5.3 One private-submodule convention

Every domain gets exactly this shape, no exceptions:

- `NeoFaker.<Domain>.Generator` — all value-producing logic for that domain. If a domain's
  generator code is large enough to want more than one file, it's split by sub-concern with a
  `*Generator` suffix, never a bare noun: `NeoFaker.Internet.UsernameGenerator`,
  `NeoFaker.Internet.EmailGenerator`, `NeoFaker.Internet.DomainGenerator`,
  `NeoFaker.Internet.TldGenerator`, `NeoFaker.HTTP.HeaderGenerator`,
  `NeoFaker.HTTP.StatusCodeGenerator`, `NeoFaker.HTTP.UserAgentGenerator`,
  `NeoFaker.Crypto.HashGenerator`, `NeoFaker.App.NameGenerator`, `NeoFaker.App.SemverGenerator`,
  `NeoFaker.App.DomainGenerator`, `NeoFaker.Color.CmykGenerator` (etc., one per format),
  `NeoFaker.Lorem.Generator` (replacing `Parser`), `NeoFaker.EnUs.Person.Generator` /
  `NeoFaker.IdId.Person.Generator` (replacing `Utils`). `Text.EmojiGenerator` and
  `Person.NameGenerator`/`FullNameGenerator` already fit and are untouched.
- `NeoFaker.<Domain>.Validator` — unchanged pattern, already consistent everywhere.
- `blood.ex` gets a `NeoFaker.Blood.Generator` even though today's logic is a one-liner
  `Enum.random/1` — consistency over cleverness; it costs one small file.
- No bare `import` of any project module anywhere. `app.ex`'s `import NeoFaker.App.Name` /
  `import NeoFaker.App.Semver` become `alias ... , as: NameGenerator` / `alias ...
  SemverGenerator` with explicit prefixed calls, matching every other context.

### 5.4 Locale-exclusive module namespace

Move `NeoFaker.EnUs.*` / `NeoFaker.IdId.*` under an explicit parent namespace,
`NeoFaker.Locales.EnUs.*` / `NeoFaker.Locales.IdId.*`, and drop the regex in
`mix.exs` in favor of a literal prefix check (`String.starts_with?(to_string(mod),
"Elixir.NeoFaker.Locales.")`). This makes "is this a locale-exclusive module" a structural fact
instead of a coincidence of casing, and scales to any future locale code shape.

### 5.5 File naming

`lib/neo_faker/HTTP.ex` → `lib/neo_faker/http.ex` (module name `NeoFaker.HTTP` is unaffected —
Elixir file names don't have to match module names, but the convention everywhere else in this
repo is that they do). Same for the `HTTP/` subdirectory and its contents.

## 6. Backend redesign

### 6.1 Locale: process-scoped override, Application env as static default only

- `Application.get_env(:neo_faker, :locale)` remains the source for the *startup* default —
  this is the correct, idiomatic use of application config (a static value read once, exactly
  what Phoenix's `config/dev.exs`/`config/test.exs` pattern in `getting-started.md` already
  assumes).
- `NeoFaker.set_locale/1` changes to write a **process-dictionary** value instead of mutating
  application env. `NeoFaker.Data.resolve_locale_config/1` checks, in order: explicit
  `locale:` option → process-dictionary override → application env → `:default`. This gives
  every test (and every process) its own locale without `async: false`, with zero change to
  the public call shape (`set_locale/1` / `get_locale/0` / `locale/0` keep their names and
  arity).
- `NeoFaker.start/0` keeps validating the application-env value at boot (so a bad
  `config :neo_faker, locale: :bogus` still fails loudly and immediately, per §4.1's last
  point) — this behavior is preserved, just re-documented with an explicit `@spec` note that
  it can raise.

### 6.2 RNG: stop reseeding

- Delete the `:rand.seed(:exsplus, :os.timestamp())` call in `Data.put_cache!/3` entirely.
  OTP seeds `:rand` automatically per process on first use; NeoFaker has no business
  overriding that.
- Add `NeoFaker.seed/1`, a thin documented wrapper over `:rand.seed/2` (default algorithm
  `:exsplus`), purely so `getting-started.md` has an official, discoverable answer to "how do
  I get reproducible output in a test" instead of users having to know `:rand` internals.

### 6.3 `NeoFaker.Data`

No structural change beyond what falls out of §6.1 — `validate_file_name!/1`'s path-traversal
guard, the `:persistent_term` caching, and the `Code.eval_string/3`-based `.exs` data loading
stay as-is (they're already correct and match Faker-ecosystem norms for this kind of static
data). Only the reseed side effect and the locale-source lookup order change.

## 7. Public API redesign

### 7.1 `keyword()` everywhere

Replace every `Keyword.t()` typespec used for an `opts` parameter with `keyword()`
package-wide. Mechanical, `mix format`-safe, zero behavior change.

### 7.2 Options/validation helpers

**Decided: adopt `NimbleOptions`.** It replaces `NeoFaker.Helpers.Options` entirely: every
domain function gets a module-level `@options_schema` (via `NimbleOptions.new!/1`) instead of
hand-rolled `Options.get/3` + `Validator.validate_x!/1` pairs, validated once via
`NimbleOptions.validate!/2` at the top of the function. This is a real, if small, new runtime
dependency, accepted because it's maintained by José Valim's team and is the same tool Ecto,
Phoenix LiveView, Broadway, and Oban already standardize on — matching §2's "official
convention" goal outweighs the zero-deps property here. `NeoFaker.Helpers.Formatter` is
unaffected (it's output formatting, not option parsing) and stays.

### 7.3 `Color.random/1` return shape

Document explicitly, in the `@doc`, that the return shape is intentionally polymorphic because
the function's entire purpose is picking a random *format*; add a
`@spec random(keyword()) :: NeoFaker.Color.any_color()` with a public `@type any_color ::
tuple() | String.t()` so the ambiguity is named instead of implicit. No behavior change.

### 7.4 `NeoFaker.locale/0` contract

Add `@spec locale() :: {:ok, atom()} | :error` documentation note that an invalid
application-env value raises `ArgumentError` rather than returning `:error` — matches current
behavior, just stops the typespec from silently lying about it.

## 8. Decisions (resolved)

1. **NimbleOptions**: adopted. Reasoning accepted: maintained by José Valim's team, matches
   ecosystem convention (Ecto/LiveView/Broadway/Oban). See §7.2.
2. **Version number**: `0.15.0`.
3. **`NeoFaker.Locales` namespace move** (§5.4): confirmed, proceed.
4. **`NeoFaker.seed/1`** (§6.2): confirmed, add it.

## 9. Phased execution plan

Each phase ships independently, keeps the full suite green (`mix format --check-formatted`,
`mix credo --strict`, `mix dialyzer`, `mix test`, `mix docs`), and gets its own commit(s) —
no single giant diff.

- [x] **Phase 0 — decisions.** Resolved, see §8.
- [ ] **Phase 1 — shared kernel.** `NeoFaker.Data` locale-resolution order change,
      process-dictionary `set_locale/1`, delete `:rand.seed/2` call, add `NeoFaker.seed/1`.
      Re-enable `async: true` on `test/neo_faker_test.exs`. Highest risk, done first and in
      isolation so it's easy to bisect if anything regresses.
- [x] **Phase 2 — mechanical renames (module organization).** Done. Per §5.3 table: renamed
      every non-conforming submodule to `*Generator` (Internet's `Domain`/`Email`/`TLD`/
      `Username`, HTTP's `Header`/`StatusCode`/`UserAgent`, Crypto's `Hash`, App's `Domain`/
      `Name`/`Semver`, Color's `CMYK`/`HEX`/`HSL`/`HSLA`/`RGB`/`RGBA`/`Keyword`, Lorem's
      `Parser` → `Generator`, `EnUs`/`IdId` Person's `Utils` → `Generator`), added a
      `Blood.Generator` for consistency, renamed `HTTP.ex`/`HTTP/` → `http.ex`/`http/`.
      **Scope grew during execution**: a repo-wide grep for bare `import NeoFaker...` turned up
      13 instances beyond the two in `app.ex` originally cited in §4.2 — `address.ex`,
      `person.ex`, `lorem.ex`, `person/name_generator.ex`, `text/emoji_generator.ex` (all
      importing `NeoFaker.Data`), `color/{cmyk,hsl,hsla,rgb,rgba}.ex` (importing
      `NeoFaker.Number`), `color/keyword.ex` (importing **and** redundantly aliasing
      `NeoFaker.Data`), and `en_us/person.ex` / `id_id/person.ex` (bare, unrestricted imports of
      their own `Utils` module). All converted to `alias` + explicit prefix, per the absolute
      "no bare import of any project module" rule in §2/§5.3. Also caught and fixed one Phase-1
      regression: two tests in `neo_faker_test.exs` mutate `Application` env directly
      (bypassing `set_locale/1`) to test the raw-config validation path — that's inherently
      node-global and unsafe under `async: true` regardless of the locale redesign, so they were
      split into a new `test/neo_faker_application_env_test.exs` kept `async: false`; the rest
      of `neo_faker_test.exs` stayed `async: true`. Verified: `mix format` clean, `mix test` 325
      passed (stable across 5 different random seeds), `mix dialyzer` 0 errors, `mix docs` builds
      (pre-existing hidden-module doc-reference warnings in `changelog.md`/`neo_faker.ex`,
      unrelated to this phase, left as-is).
- [x] **Phase 3 — locale-exclusive namespace.** Done. Moved `lib/neo_faker/en_us/` and
      `lib/neo_faker/id_id/` to `lib/neo_faker/locales/en_us/` and `lib/neo_faker/locales/id_id/`
      (mirrored under `test/neo_faker/locales/`), renaming every module to
      `NeoFaker.Locales.EnUs.*` / `NeoFaker.Locales.IdId.*`. `mix.exs` `groups_for_modules/0` now
      matches the literal `NeoFaker.Locales.` prefix instead of the old casing-shape regex.
      Updated `CLAUDE.md`'s "Locale-exclusive modules" and "Tests" sections to match.
      `lib/pages/changelog.md`'s historical entries were deliberately left untouched (they
      describe what the API was called at the time of that release; Phase 5 adds a new 0.15.0
      entry documenting this move instead of rewriting history). Verified: `mix format` clean,
      `mix test` 325 passed (3 seeds), `mix dialyzer` 0 errors, `mix docs` confirms
      `NeoFaker.Locales.EnUs.Person` / `NeoFaker.Locales.IdId.Person` land in the "Locale Random
      Generators" sidebar group.
- [x] **Phase 4 — public API polish.** Done. `nimble_options ~> 1.1` added as a runtime
      dependency. Every domain's `opts` handling now goes through a module-level
      `NimbleOptions.new!/1` schema, validated once via a new
      `NeoFaker.Helpers.Options.validate!/2` (wraps `NimbleOptions.validate/2` and re-raises as
      `ArgumentError`, so the "Raises `ArgumentError`" contract in every `@doc` stays true —
      callers never see `NimbleOptions.ValidationError`). The old hand-rolled
      `Options.get/3`/`validate_enum/3`/`validate_range/3`/`get_and_validate/4` are gone.
      Domain `Validator` modules were trimmed to keep only what NimbleOptions cannot express —
      validation of **positional** arguments (a `range`, `start`/`finish`, `min`/`max`), since
      NimbleOptions only validates keyword-list options, never positional parameters; six
      validator modules that had nothing left (`Blood`, `HTTP`, `Internet`, `Lorem`, `Color`,
      `Text`) were deleted outright. `keyword()` sweep completed package-wide (zero
      `Keyword.t()` left in `lib/`).

  Findings and fixes that came out of this pass:
  - **Two real, pre-existing locale bugs, now fixed**: `NeoFaker.Person.first_name/1` (and
    `middle_name/1`, `last_name/1`, `full_name/1`) and `NeoFaker.App.name/1` hardcoded their
    locale default to the literal `:default` atom instead of consulting
    `NeoFaker.get_locale/0` — meaning `set_locale(:id_id)` followed by `Person.first_name()`
    silently kept returning English names, directly contradicting the worked example in
    `NeoFaker`'s own moduledoc. Never caught because doctests are written throughout the
    codebase but never actually wired into the test suite (confirmed: `grep -rln doctest test/`
    returns nothing). Same fix applied to `NeoFaker.Color.keyword/1`, which had the identical
    pattern. Verified live: after `set_locale(:id_id)`, `Person.first_name()` now returns a name
    traceable to `priv/data/id_id/person/female_name.exs`, not the default set.
  - **`NimbleOptions` validates default values against their own type**, including through
    `{:custom, ...}` validators — confirmed empirically (not documented behavior I assumed
    going in). This surfaced one real bug during the Gravatar conversion:
    `fallback: [type: {:custom, ..., :validate_and_format_fallback, []}, default: "identicon"]`
    failed at every call, because the custom validator's string-branch requires an `http(s)://`
    URL — the default has to be given in whatever shape the validator itself accepts as input
    (here, the atom `:identicon`, which the validator then transforms to `"identicon"`), not
    pre-transformed.
  - **One pre-existing test bug fixed**: `test/neo_faker/lorem_test.exs` asserted on a
    `type: :meditations` option that Lorem's implementation never read (the real, documented
    option is `:text`) — passed vacuously before because unknown keys were silently ignored;
    NimbleOptions' strictness caught it. Fixed to `text: :meditations`.
  - **`NeoFaker.Internet.EmailGenerator` simplified**: it used to fall back from
    `:username_word_count` to a bare, undocumented `:word_count` (and similarly for the domain
    and TLD sub-options) — none of that fallback was ever mentioned in `email/1`'s own `@doc`.
    Dropped in favor of reading only the documented prefixed keys directly.
  - **`NeoFaker.Color.random/1`** return shape is now named via a public `@type any_color ::
    tuple() | String.t()`, with a `@typedoc` explaining the polymorphism is intentional (picking
    a random *format*), not an accident.
  - `NeoFaker.locale/0`'s doc/spec note (that it can raise on a bad application-env value) was
    already added back in Phase 1 — nothing further needed here.
  - Message-text churn: several `assert_raise ArgumentError, ~r/.../` tests were updated where
    NimbleOptions' own message format differs from the old hand-written one (e.g.
    `Internet.domain_name/1`'s non-string `:domain_name` check). Custom, function-specific
    messages (e.g. Address's "invalid :type for building_number/2") were preserved by using
    `{:custom, Module, :fun, []}` validators — NimbleOptions wraps custom messages rather than
    replacing them, so the original wording still appears (as a substring) in the raised error.

  Verified: `mix format` clean, `mix test` 325 passed (3 seeds), `mix dialyzer` 0 errors,
  `mix docs` builds (only the same pre-existing hidden-module warnings from earlier phases).
- [ ] **Phase 5 — docs & changelog.** Update `CLAUDE.md` architecture section,
      `getting-started.md` (seed usage, locale semantics), `CHANGELOG.md` entry describing the
      breaking changes, bump `mix.exs` version to `0.15.0`.
- [ ] **Phase 6 — final verification.** Full `mise run format|lint|analyze|fix` chain, `mix
      docs` clean build, smoke-test against the same throwaway Phoenix app used earlier in this
      project to confirm the process-scoped locale change doesn't break the documented Phoenix
      integration path.

Each phase's checkbox is ticked in this file as it lands, so the plan doc doubles as the
progress tracker.
