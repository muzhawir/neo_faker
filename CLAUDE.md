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
mix docs # build ExDoc documentation (uses lib/pages/*.md, *.cheatmd)
```

`mise.toml` defines composite tasks (`mise run format|lint|analyze|fix`) that chain the above in order: format → credo → dialyzer → test.

Two CI workflows mirror these checks: `lint.yml` (format check + credo + test, runs on PRs into non-main branches) and `build.yml`
(format check + credo + dialyzer + test, runs on `main`). Any change should pass `mix format --check-formatted`, `mix credo --strict`, and `mix test`
before being considered done; run `mix dialyzer` too when types/specs changed.

## Architecture

### Domain modules and their internal split

Each public-facing generator lives at `lib/neo_faker/<domain>.ex` (e.g. `NeoFaker.Address`, `NeoFaker.Person`, `NeoFaker.Internet`, `NeoFaker.Color`,
`NeoFaker.Crypto`). These modules hold the documented public API (with `@doc`/`@spec`/doctests) and delegate implementation details to private
submodules in `lib/neo_faker/<domain>/`:

- `Generator` — pure computation/randomization logic (e.g. `Address.Generator` builds lat/long).
- `Validator` — argument validation, raises `ArgumentError` with a descriptive message on bad input (e.g. invalid `:type`, out-of-range values).
  Tests assert on these via `assert_raise ArgumentError, ~r/.../, fn -> ... end`.

Some domains use more specific submodule names instead of a generic `Generator` (`Person.NameGenerator`, `Person.FullNameGenerator`,
`Text.EmojiGenerator`, `Lorem.Parser`).

Keep this generator/validator separation when adding new domains or functions: don't inline validation or randomization logic into the public module
— put it in the matching submodule.

### Locale system

`NeoFaker.Data` (`lib/neo_faker/data.ex`) is the single data-loading layer used by every domain module via `random_value/4` (and `fetch!/3` directly
in tests). It reads locale data from `priv/data/<locale>/<module_dir>/<file>.exs`, where `<module_dir>` is the calling module's last name segment,
lowercased (derived automatically via `Module.split/1`).

Key points:

- `priv/data/locale.exs` is the source of truth for supported locale codes (currently `en_us`, `id_id`). `NeoFaker.Data.supported_locales/0` and
  `locale_available?/1` read from it.
- `:default` is a special locale that is _not_ listed in `locale.exs` — `priv/data/default/` holds the baseline (US English) data set. There is no
  `priv/data/en_us/` directory; `:en_us` falls back to `:default` data unless a locale-specific override file exists.
- If a locale-specific data file doesn't exist for a given module/file, `NeoFaker.Data` silently falls back to `:default` rather than erroring
  (`ensure_locale_file_exists/3`).
- Locale data is cached in `:persistent_term` after first read (per locale/module/file), and values are shuffled once at cache time, not re-randomized
  per call — `Enum.random/1` picks from the cached shuffled list on every call.
- `validate_file_name!/1` restricts data file names to a bare filename ending in `.exs` — this guards against path traversal / arbitrary file eval
  via `Code.eval_string/3`. Never bypass this when adding new data lookups.
- Global/default locale is configured via `Application.put_env(:neo_faker, :locale, ...)`, managed through `NeoFaker.set_locale/1`,
  `NeoFaker.locale/0`, `NeoFaker.get_locale/0`. Any domain function accepts a per-call `locale:` option that overrides the global setting.

### Locale-exclusive modules

Some functionality only makes sense for one locale (e.g. US Social Security Numbers) and isn't expressed as a `locale:` option on a shared function.
These live under `lib/neo_faker/<locale>/` with locale-cased module names, e.g. `NeoFaker.EnUs.Person.ssn/0` (`lib/neo_faker/en_us/person.ex`) and
`NeoFaker.IdId.Person` (`lib/neo_faker/id_id/person.ex`). `mix.exs`'s `groups_for_modules/0` splits ExDoc's sidebar into "Random Generators" vs.
"Locale Random Generators" using a regex over the module name shape (`NeoFaker.XxYy.*`), so keep this naming convention when adding new
locale-exclusive modules.

### Shared helpers

`lib/neo_faker/helpers/`:

- `Options` — keyword-list option handling: `get/3`, `get_many/2` (schema-based), `validate_enum/3`, `validate_range/3`, `validate_many/2`,
  `get_and_validate/4`. Prefer these over ad hoc `Keyword.get/3` + manual validation when a domain module parses `opts`.
- `Formatter` — shared output formatting (e.g. numbers to string).

### Tests

Test files mirror `lib/` under `test/neo_faker/`, including locale-exclusive subdirectories (`test/neo_faker/en_us/`, `test/neo_faker/id_id/`).
Tests commonly call `NeoFaker.Data.fetch!/3` directly to pull the full cached data set for a module/file and assert generated values are drawn from it
(see `test/neo_faker/address_test.exs`). `test/test_helper.exs` calls `NeoFaker.start()` before the suite runs, so a locale is always configured
during tests.
