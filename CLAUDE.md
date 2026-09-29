# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

NeoFaker is a fake data generator library for Elixir (published on Hex), used for tests and
development environments. Requires Elixir `~> 1.18`.

## Commands

```bash
mix deps.get # install dependencies
mix format # format code (Styler plugin, line_length: 98)
mix format --check-formatted # CI-style format check, no writes
mix credo --strict # static analysis (must pass with --strict in CI)
mix dialyzer # type checking (build-only CI job, not lint-only job)
mix test # run full test suite
mix test test/neo_faker/address_test.exs # run one test file
mix test test/neo_faker/address_test.exs:42 # run a single test at a line
mix docs # regenerate both cheatsheets, then build ExDoc documentation (lib/pages/{guides,reference,contributing,about}/*)
mix docs.cheatsheet # regenerate lib/pages/reference/{cheat,locale-cheat}.cheatmd from @doc examples
mix docs.cheatsheet --check # fail if either cheatsheet is stale (runs in CI)
```

`mise.toml` defines composite tasks (`mise run format|lint|analyze|fix`) that chain the above in order: format → credo → dialyzer → test.

Two CI workflows mirror these checks, both running every step with `MIX_ENV=test` and `mix compile --warnings-as-errors`:

- `lint.yml` (PRs into non-main branches): one job, single toolchain, running format check + credo + cheatsheet check + test.
- `build.yml` (push/PR to `main`): a `test` job matrixed over the oldest supported toolchain (Elixir 1.18 / OTP 27, the `~> 1.18` floor)
  and the current one (kept in sync with `mise.toml`), plus a `static` job on the current toolchain running format check + credo + cheatsheet check + dialyzer.
  Dialyzer's PLT is cached via the `:dialyzer` `plt_local_path` config in `mix.exs` (`priv/plts/`, gitignored).

Any change should pass `mix format --check-formatted`, `mix credo --strict`, and `mix test` before being considered done; run `mix dialyzer`
too when types/specs changed.

## Elixir documentation lookup

When you need official Elixir documentation (module reference, guides, anti-patterns, meta-programming, etc.), start from the index at
https://elixir.hexdocs.pm/llms.txt, which lists every page and module with its relative path, e.g. `[Enum](Enum.md)`,
`[Code anti-patterns](code-anti-patterns.md)`.

Always fetch documentation pages as `.md`, never `.html`: take the filename from `llms.txt` and request
`https://elixir.hexdocs.pm/<version>/<filename>.md` (e.g. `https://elixir.hexdocs.pm/1.20.4/code-anti-patterns.md`, not `.../code-anti-patterns.html`).
The `.md` version is the plain-text source and is far cheaper to fetch and read than the rendered HTML page.

## Architecture

### Domain modules and their internal split

Each public-facing generator lives at `lib/neo_faker/<domain>.ex` (e.g. `NeoFaker.Address`, `NeoFaker.Person`, `NeoFaker.Internet`, `NeoFaker.Color`,
`NeoFaker.Crypto`). These modules hold the documented public API (with `@doc`/`@spec`/doctests) and delegate implementation details to private
submodules in `lib/neo_faker/<domain>/`:

- `Generator` handles pure computation/randomization logic (e.g. `Address.Generator` builds lat/long). If a domain's generator logic is large
  enough to split further, sub-parts get a `*Generator` suffix (`Internet.UsernameGenerator`, `HTTP.HeaderGenerator`, `Internet.TldGenerator`, etc.),
  never a bare feature name.
- `Validator` holds domain-specific checks: positional-argument checks that raise `ArgumentError` (e.g. `Date.Validator.validate_date_order!/2`)
  and `{:ok, value} | {:error, message}` functions used as NimbleOptions `{:custom, ...}` types (e.g. `App.Validator.validate_domain/1`).
  Checks shared by several domains (non-empty ranges, non-negative bounds) live in `NeoFaker.Helpers.Validator` instead; a domain that needs
  nothing beyond those has no `Validator` module at all (e.g. `Address`, `Person`, `Blood`, `Color`, `Text`).

Some domains use more specific submodule names instead of a generic `Generator` (`Person.NameGenerator`, `Person.FullNameGenerator`,
`Text.EmojiGenerator`, `Lorem.Generator`). All of these submodules are `@moduledoc false`, never part of the public API, so renaming or
reorganizing them is not a breaking change to consumers.

Keep this generator/validator separation when adding new domains or functions: don't inline randomization logic into the public module. Instead,
put it in the matching submodule. Never use a bare `import` of another project module (stdlib macro imports like `import Bitwise` are fine); always `alias`
and call with an explicit prefix, so it's clear at the call site where a function comes from.

### Options handling

Every function that accepts a keyword-list `opts` parameter validates it with `NimbleOptions`, not by hand. The pattern:

```elixir
@my_schema NimbleOptions.new!(
             format: [type: {:in, [:struct, :iso8601]}, default: :struct]
           )

def my_function(opts \\ []) do
  opts = NimbleOptions.validate!(opts, @my_schema)
  # ... use opts[:format]
end
```

Call `NimbleOptions.validate!/2` directly; there is no wrapper. Invalid options therefore raise `NimbleOptions.ValidationError`, not
`ArgumentError` (positional-argument validation in the `Validator` modules and unsupported-locale errors still raise `ArgumentError` directly).
For validation NimbleOptions has no built-in type for (a business rule, or a message that must name the specific function), write a
`{:ok, value} | {:error, message}` function in the domain's `Validator` module and reference it as `type: {:custom, Validator, :fun_name, []}`.
NimbleOptions wraps whatever message that function returns in a `NimbleOptions.ValidationError`; it doesn't replace it. **NimbleOptions validates
default values against their own type too** (including through `{:custom, ...}` validators). A schema default must independently satisfy its own
type spec, or every call using that default will raise.

When one function forwards a subset of its own already-validated `opts` to another function that has its own independent schema, extract exactly
that subset with `Keyword.take/2` first (see `NeoFaker.Internet.EmailGenerator` for an example), since NimbleOptions raises on any key a schema
doesn't declare, so passing the full opts list through unchanged only works when every downstream schema declares the same keys.

### Documentation style

`@moduledoc`/`@doc` content follows the wording and structure used by Elixir's own stdlib docs
(`String`, `Enum`, `Date`, `Time`, `Path`), not an ad hoc house style. When writing or editing a
public function's docs:

- First line: one concise, imperative sentence (`"Generates a random X."`, `"Returns Y."`). A
  short prose paragraph after it may explain non-obvious behavior or mention a positional
  parameter's role/default by name. Don't add a separate "## Parameters" heading for that, since
  it's redundant with the `@spec` and the prose.
- Keyword-list options go under a single `## Options` heading, one `*` bullet per key:
  `` * `:key` (type or allowed values) - description. Defaults to `value`. `` When an option
  takes several named atoms that each need explaining, nest a nested `*` list under that
  option's bullet instead of a free-floating "The values for `:x` can be:" paragraph.
- Keep `## Examples` with `iex>` blocks. Results must be values the function can actually return.
- Error messages start in lowercase and name the offending value: `"count must be a positive integer, got: 0"`.

See `lib/neo_faker/blood.ex` or `lib/neo_faker/color.ex` for compact examples, and
`lib/neo_faker/internet.ex`'s `email/1` for a composite function that groups options by the
sub-function they're forwarded to (`## Username options`, `## Domain name options`, etc.).

### Locale system

`NeoFaker.Locale` (`lib/neo_faker/locale.ex`) is the single owner of locale state and the list of supported locale codes. `NeoFaker.Data`
(`lib/neo_faker/data.ex`) is the data-loading layer used by every domain module via `random_value/4` (and `fetch!/3` directly in tests); it depends
one-way on `NeoFaker.Locale` to resolve which locale is active, never the other way around. It reads locale data from
`priv/data/<locale>/<module_dir>/<file>.exs`, where `<module_dir>` is the calling module's last name segment, lowercased (derived automatically via
`Module.split/1`).

Key points:

- The `@supported_locales` module attribute in `NeoFaker.Locale` (`lib/neo_faker/locale.ex`) is the source of truth for supported locale codes
  (currently `en_us`, `id_id`). `NeoFaker.Locale.supported/0` and `available?/1` read from it. Adding a locale is a code change regardless (it needs
  `priv/data/<code>/` files and usually a `lib/neo_faker/locales/<code>/` module), so the list lives next to the code that enforces it, not in a data file.
- `:default` is a special locale that is _not_ in `@supported_locales`, since `priv/data/default/` holds the baseline (US English) data set. There is no
  `priv/data/en_us/` directory; `:en_us` falls back to `:default` data unless a locale-specific override file exists.
- If a *supported* locale has no data file for a given module/file, `NeoFaker.Data` falls back to the `:default` copy of that file, for
  `random_value/4` and `fetch!/3` alike. An *unsupported* locale is never a fallback case: `NeoFaker.Locale.validate!/1` raises `ArgumentError`,
  and every schema declares `locale: [type: {:custom, NeoFaker.Locale, :validate_option, []}, default: nil]` so a bad per-call `locale:` raises
  `NimbleOptions.ValidationError` first.
- Locale data is cached in `:persistent_term` after first read, keyed by `{NeoFaker.Data, requested_locale, module, file}`, so a fallback costs one
  `File.exists?/1` on the first read only. Each list is deduplicated with `Enum.uniq/1` at cache time but kept in file order; the per-call pick
  is `Enum.random/1`, so randomness happens per call, not at cache time.
- `random_value/4` takes either one key or a list of keys. A list draws from the union of those lists with duplicates removed (e.g. color
  `:all` pools `"basic"` and `"extended"`, which overlap), cached via `derive!/5`. Use a key list rather than `Map.values |> List.flatten` in
  generators, which would over-weight values listed under several keys.
- `derive!/5` caches any value computed from a data file (e.g. `Lorem.Generator` splits its text into paragraphs once). Use it for any
  preprocessing that would otherwise run on every call.
- The locale segment (checked by `NeoFaker.Locale.validate!/1`) and `validate_file_name!/1` (a bare filename ending in `.exs`) together keep
  every path handed to `Code.eval_string/3` inside `priv/data/`. Never bypass either when adding new data lookups.
- Locale resolution has two layers, checked in order by `NeoFaker.Locale.fetch/0`: a **process-scoped** override set via `NeoFaker.Locale.set/1`
  (stored in the process dictionary, so it never leaks between processes, which is safe under `async: true` tests), then `config :neo_faker,
  locale: ...` (`Application.get_env/2`, the static default for the whole node, e.g. what a Phoenix app sets in `config/dev.exs`/`config/test.exs`).
  `NeoFaker.Locale.get/0` wraps this and always returns an atom (`:default` when neither layer is set). Any locale-aware domain function accepts a
  per-call `locale:` option that overrides both layers for that one call. The old top-level `NeoFaker.locale/0`, `set_locale/1`, and
  `get_locale/0` were removed in v0.15.0.

### Locale-exclusive modules

Some functionality only makes sense for one locale (e.g. US Social Security Numbers) and isn't expressed as a `locale:` option on a shared function.
These live under `lib/neo_faker/locales/<locale>/`, namespaced under `NeoFaker.Locales.*` with locale-cased module names, e.g.
`NeoFaker.Locales.EnUs.Person.ssn/0` (`lib/neo_faker/locales/en_us/person.ex`) and `NeoFaker.Locales.IdId.Person`
(`lib/neo_faker/locales/id_id/person.ex`). `mix.exs`'s `groups_for_modules/0` splits ExDoc's sidebar into "Random Generators" vs. "Locale Random
Generators" by matching the literal `NeoFaker.Locales.` prefix, so keep every locale-exclusive module under that namespace.

A locale-exclusive module that needs a data set reads it through `NeoFaker.Data` with an explicit `locale:` (it must not depend on the active
locale), e.g. `NeoFaker.Locales.IdId.Person.Generator` reads the official district codes for NIK from `priv/data/id_id/person/region_code.exs`
(derived from the last module segment, `Person`). That file is generated from third-party data; keep its source and license header.

### Shared helpers

`lib/neo_faker/helpers/`:

- `Formatter` provides shared string shaping: `apply_case/2`, and `slugify/1`, which reduces a word to lowercase ASCII letters and digits
  (keeping the base letter of accented characters) for usernames, domain labels, and slugs.
- `Validator` provides argument checks shared by several domains: `validate_range!/2` (a non-empty range; checked with `Range.size/1`, not
  `first <= last`, so descending stepped ranges pass and empty ones fail), `validate_range_option/1` (the same, as a NimbleOptions custom type),
  and `validate_non_neg_bounds!/3` (a `min`/`max` pair of non-negative integers).

Options parsing has no shared helper: every domain module calls `NimbleOptions.validate!/2` directly (see "Options handling" above) instead of
ad hoc `Keyword.get/3` + manual validation.

### Tests

Test files mirror `lib/` under `test/neo_faker/`, including locale-exclusive subdirectories (`test/neo_faker/locales/en_us/`, `test/neo_faker/locales/id_id/`).
Tests commonly call `NeoFaker.Data.fetch!/3` directly to pull the full cached data set for a module/file and assert generated values are drawn from it
(see `test/neo_faker/address_test.exs`). `test/test_helper.exs` calls `NeoFaker.start()` before the suite runs, which starts the application and
validates the configured locale.

**Doctests are not wired up, on purpose.** Every public function has `## Examples` with `iex>` blocks, but their results are random, so no test
file has a `doctest NeoFaker.X` call and `mix test` never executes them. A `@doc` example can therefore drift from actual behavior; don't treat an
accurate-looking `## Examples` block as verified, and keep examples to values the function can really return (e.g. no `"josé"` in a username,
which is always ASCII).

Both cheatsheets (`lib/pages/reference/cheat.cheatmd` and `locale-cheat.cheatmd`) are generated from those `## Examples` blocks by
`scripts/gen_cheatsheet.exs`, run through the `mix docs.cheatsheet` alias (and automatically by `mix docs`). Edit the `@doc`, then rerun it; never
edit a cheatsheet by hand, since CI runs `mix docs.cheatsheet --check`. Modules are discovered from the compiled app: every public module except
`NeoFaker` and `NeoFaker.Locale` is included, `NeoFaker.Locales.*` modules go to the locale cheatsheet, and a new locale code needs a section
title in the script's `@locale_names`. (`scripts/` is not in the Hex package.)

`mix docs` must build without warnings. The changelog is exempt from reference checks
(`skip_undefined_reference_warnings_on` in `mix.exs`), since it names functions as they were at each release;
everywhere else, never reference a `@moduledoc false` module or a removed function in backticks.

A test that mutates `Application` env directly (bypassing `NeoFaker.Locale.set/1`, e.g. to test the raw-config validation path in
`NeoFaker.Locale.fetch/0`) is node-global and must not run `async: true` alongside anything else that reads `config :neo_faker, locale: ...`. See
`test/neo_faker/locale_application_env_test.exs`.
