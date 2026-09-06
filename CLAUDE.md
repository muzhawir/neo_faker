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
mix docs # build ExDoc documentation (uses lib/pages/{guides,reference,about}/*)
```

`mise.toml` defines composite tasks (`mise run format|lint|analyze|fix`) that chain the above in order: format → credo → dialyzer → test.

Two CI workflows mirror these checks, both running every step with `MIX_ENV=test` and `mix compile --warnings-as-errors`:

- `lint.yml` (PRs into non-main branches): one job, single toolchain, running format check + credo + test.
- `build.yml` (push/PR to `main`): a `test` job matrixed over the oldest supported toolchain (Elixir 1.18 / OTP 27, the `~> 1.18` floor)
  and the current one (kept in sync with `mise.toml`), plus a `static` job on the current toolchain running format check + credo + dialyzer.
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
  enough to split further, sub-parts get a `*Generator` suffix (`Internet.UsernameGenerator`, `HTTP.HeaderGenerator`, `Crypto.HashGenerator`, etc.),
  never a bare feature name.
- `Validator` handles validation for **positional** function arguments only (a `range`, `start`/`finish`, `min`/`max`), raising `ArgumentError` with a
  descriptive message. Keyword-list **options** (`opts`) are validated by a `NimbleOptions` schema instead (see "Options handling" below); a domain
  with no positional arguments to validate has no `Validator` module at all (e.g. `Blood`, `HTTP`, `Internet`, `Lorem`, `Color`, `Text`).

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
- Keep `## Examples` with `iex>` doctests as-is.

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

- `priv/data/locale.exs` is the source of truth for supported locale codes (currently `en_us`, `id_id`). `NeoFaker.Locale.supported/0` and
  `available?/1` read from it.
- `:default` is a special locale that is _not_ listed in `locale.exs`, since `priv/data/default/` holds the baseline (US English) data set. There is no
  `priv/data/en_us/` directory; `:en_us` falls back to `:default` data unless a locale-specific override file exists.
- If a locale-specific data file doesn't exist for a given module/file, `NeoFaker.Data` silently falls back to `:default` rather than erroring
  (`ensure_locale_file_exists/3`).
- Locale data is cached in `:persistent_term` after first read (per locale/module/file), keyed by the `{NeoFaker.Data, locale, module, file}` tuple.
  Each list in the file is deduplicated with `Enum.uniq/1` at cache time but kept in file order; the per-call pick is `Enum.random/1` on the cached
  list (`NeoFaker.Data.random_value/4`), so randomness happens per call, not at cache time.
- `validate_file_name!/1` restricts data file names to a bare filename ending in `.exs`, which guards against path traversal / arbitrary file eval
  via `Code.eval_string/3`. Never bypass this when adding new data lookups.
- Locale resolution has two layers, checked in order by `NeoFaker.Locale.fetch/0`: a **process-scoped** override set via `NeoFaker.Locale.set/1`
  (stored in the process dictionary, so it never leaks between processes, which is safe under `async: true` tests), then `config :neo_faker,
  locale: ...` (`Application.get_env/2`, the static default for the whole node, e.g. what a Phoenix app sets in `config/dev.exs`/`config/test.exs`).
  `NeoFaker.Locale.get/0` wraps this and always returns an atom (`:default` when neither layer is set). Any domain function accepts a per-call
  `locale:` option that overrides both layers for that one call. `NeoFaker.locale/0`, `set_locale/1`, and `get_locale/0` still exist as `@deprecated`
  delegates to `NeoFaker.Locale.*` for backward compatibility; use the `NeoFaker.Locale` names in new code.

### Locale-exclusive modules

Some functionality only makes sense for one locale (e.g. US Social Security Numbers) and isn't expressed as a `locale:` option on a shared function.
These live under `lib/neo_faker/locales/<locale>/`, namespaced under `NeoFaker.Locales.*` with locale-cased module names, e.g.
`NeoFaker.Locales.EnUs.Person.ssn/0` (`lib/neo_faker/locales/en_us/person.ex`) and `NeoFaker.Locales.IdId.Person`
(`lib/neo_faker/locales/id_id/person.ex`). `mix.exs`'s `groups_for_modules/0` splits ExDoc's sidebar into "Random Generators" vs. "Locale Random
Generators" by matching the literal `NeoFaker.Locales.` prefix, so keep every locale-exclusive module under that namespace.

### Shared helpers

`lib/neo_faker/helpers/`:

- `Formatter` provides shared output formatting (e.g. numbers to string).

Options parsing has no shared helper: every domain module calls `NimbleOptions.validate!/2` directly (see "Options handling" above) instead of
ad hoc `Keyword.get/3` + manual validation.

### Tests

Test files mirror `lib/` under `test/neo_faker/`, including locale-exclusive subdirectories (`test/neo_faker/locales/en_us/`, `test/neo_faker/locales/id_id/`).
Tests commonly call `NeoFaker.Data.fetch!/3` directly to pull the full cached data set for a module/file and assert generated values are drawn from it
(see `test/neo_faker/address_test.exs`). `test/test_helper.exs` calls `NeoFaker.start()` before the suite runs, so a locale is always configured
during tests.

**Doctests are not wired up.** Every public function has `## Examples` with `iex>` blocks, but no test file has a `doctest NeoFaker.X` call, so
`mix test` never executes them (`grep -rln doctest test/` returns nothing), meaning a `@doc` example can silently drift from actual behavior. Don't treat
an accurate-looking `## Examples` block as verified; check the real function if the behavior matters.

A test that mutates `Application` env directly (bypassing `set_locale/1`, e.g. to test the raw-config validation path in `NeoFaker.locale/0`) is
node-global and must not run `async: true` alongside anything else that reads `config :neo_faker, locale: ...`. See
`test/neo_faker_application_env_test.exs`.
