# Changelog

## v0.15.0 (2026-03-11)

### Features

- Added `NeoFaker.Data.supported_locales/0` to expose the canonical list of supported locale atoms
  (read from `priv/data/locale.exs` and cached in `:persistent_term`).
- Added `NeoFaker.Gravatar.profile/2` for generating Gravatar profile page URLs with `:format`
  support (`:html`, `:json`, `:xml`, `:php`, `:vcf`, `:qr`).
- Added `NeoFaker.Gravatar.random/0` for generating a Gravatar image URL with a randomly selected
  size and fallback type.
- Added `NeoFaker.Gravatar.fallback_types/0`, `NeoFaker.Gravatar.default_size/0`, and
  `NeoFaker.Gravatar.size_range/0` as public introspection helpers.
- Added `NeoFaker.Gravatar.display/2` options `:rating` (`:g`, `:pg`, `:r`, `:x`) and
  `:force_default` (appends `&f=y` when `true`).
- Added `NeoFaker.App.Validator.validate_domain!/1` so `App.bundle_id/1` and `App.package_name/1`
  raise a descriptive `ArgumentError` instead of a `MatchError` on invalid domain strings.
- Added `NeoFaker.Internet.Validator.validate_ipv4_class!/1` so `Internet.ipv4/1` raises
  `ArgumentError` on invalid `:class` values instead of `FunctionClauseError`.

### Improvements

- **`NeoFaker.set_locale/1`** — The `ArgumentError` message for unsupported locales now lists the
  available locale atoms dynamically (sourced from `priv/data/locale.exs` via
  `NeoFaker.Data.supported_locales/0`), so the message is always accurate as new locales are added.
- **`NeoFaker.Data`** — `@locale_file` now resolves using `:code.priv_dir(:neo_faker)` instead of
  `File.cwd!/0`, fixing resolution when NeoFaker is used as a Mix dependency.
- **`NeoFaker.Data`** — Refactored `locale_available?/1` and the new `supported_locales/0` to
  share a single private `load_locale_set/0` helper, keeping the `:persistent_term` cache as the
  sole source of truth and avoiding redundant `MapSet` construction on each call.
- **`NeoFaker.Internet.Generator.public_ipv4/0`** — Completely overhauled to exclude all
  IANA-reserved ranges: `0.0.0.0/8`, `10.0.0.0/8`, `100.64.0.0/10` (CGN), `127.0.0.0/8`,
  `169.254.0.0/16`, `172.16.0.0/12`, `192.0.0.0/24`, `192.0.2.0/24`, `192.88.99.0/24`,
  `192.168.0.0/16`, `198.18.0.0/15`, `198.51.100.0/24`, `203.0.113.0/24`, `224.0.0.0/4`, and
  `240.0.0.0/4`. A compile-time cumulative weight table ensures first-octet selection is O(1).
- **`NeoFaker.Internet.Generator`** — Fixed off-by-one bug in `find_octet_in_table/2` cumulative
  table lookup. Fixed `find_longest_zero_sequence/1` to use `Stream` operations before the final
  `Enum.max_by/2` to avoid unnecessary intermediate lists.
- **`NeoFaker.Internet.url/1`** — Fixed double-TLD bug (e.g. `"gmail.com.net"`) for `:popular` and
  `:custom` domain types. The function now only appends a TLD for `:random` (word-based) domains.
  Also normalises `:domain_type` → `:type` to mirror `Email` helper behaviour.
- **`NeoFaker.Crypto.token/2`** — Fixed guard `when is_integer(length) or length < 1` (which
  matched any integer) to `when is_integer(length) and length < 1`, so only truly non-positive
  integers raise `ArgumentError`.
- **`NeoFaker.Number.decimal/3`** — Now delegates to `between/2` before rounding, inheriting its
  `min > max` validation and raising `ArgumentError` for inverted ranges.
- **`NeoFaker.Text.Generator.character/1`** — Removed per-call `Enum.shuffle/1`; character pools
  are precomputed as module attributes and sampled with `Enum.random/1`, reducing per-call
  allocations and eliminating unnecessary O(n) work.
- **`NeoFaker.set_locale/1`** — Now validates the supplied atom against
  `NeoFaker.Data.supported_locales/0` before storing it; previously accepted any atom, which could
  silently poison application state.

### Bug Fixes

- `NeoFaker.App.bundle_id/1` and `App.package_name/1` no longer raise `MatchError` on domains
  that contain no dot or are empty strings; a clear `ArgumentError` is raised instead.
- `NeoFaker.Internet.ipv4/1` no longer raises `FunctionClauseError` for unsupported `:class`
  values; `ArgumentError` is raised with a descriptive message.
- `NeoFaker.Internet.Generator.public_ipv4/0` previously could generate loopback, private,
  link-local, multicast, CGN, and various test/documentation ranges. All reserved ranges are now
  excluded (see Improvements above).

### Tests

- Test count grew from **132** (pre-refactor baseline) to **245** (current), all passing.
- Added exhaustive `NeoFaker.GravatarTest` coverage: size validation, fallback atoms and URL
  strings, `:rating` and `:force_default` parameters, `profile/2` formats, `random/0`, and all
  introspection helpers (`fallback_types/0`, `default_size/0`, `size_range/0`).
- Added `NeoFaker.InternetTest` coverage: public IPv4 reserved-range exclusions (50-iteration
  property loop), private IPv4 class variants, `ipv6/1` format checks, `url/1` double-TLD
  regression, `slug/2` separator and word-count edge cases.
- Added `NeoFaker.AppTest` coverage: `bundle_id/1` and `package_name/1` domain validation error
  paths (no dot, empty string, non-string).
- Added `NeoFaker.CryptoTest` coverage: `token/2` non-positive integer and non-integer length
  errors, hash format regex checks.
- Added `NeoFaker.NumberTest` coverage: `decimal/3` inverted-range error, bounds, and precision;
  `between/2` mixed-type float generation.
- Added `NeoFakerTest` coverage: `set_locale/1` accepts `:default`, raises on unsupported atom,
  error message dynamically lists all supported locales, error message references documentation.

### Breaking Changes

- **`NeoFaker.set_locale/1`** now raises `ArgumentError` for atom values that are not in
  `priv/data/locale.exs` (or `:default`). Code that previously called `set_locale(:some_typo)`
  without error will now raise. Use `NeoFaker.Data.supported_locales/0` to enumerate valid values.
- **`NeoFaker.Internet.ipv4/0`** (public mode) no longer returns private, loopback, link-local,
  CGN, or any other IANA-reserved address. Callers that depended on receiving reserved ranges must
  switch to `ipv4(private: true)` or generate octets directly.

## v0.14.0 (2026-03-11)

### Features

- Added `NeoFaker.Helpers.Formatter` for standardized format conversions.
- Added `NeoFaker.Helpers.Options` for consistent option extraction and validation.
- Added `NeoFaker.IdId.Person.npwp/0` for generating random Indonesian tax identification numbers (NPWP), delegating to `nik/0`.
- Added `NeoFaker.Address.Generator` sub-module with `latitude/1` and `longitude/1` generators.
- Consolidated all data-access helpers into a unified `NeoFaker.Data` module.

### Improvements

- Extracted dedicated `Validator` and `Generator` sub-modules across all major modules: `Address`, `App`, `Blood`, `Boolean`, `Color`, `Crypto`, `Date`, `Gravatar`, `HTTP`, `Internet`, `Lorem`, `Number`, `Person`, `Text`, and `Time`.
- Removed `NeoFaker.Helpers.Constants` in favour of module attributes in each module.
- Replaced `@default_locale` attribute with the `:default` atom throughout the codebase for consistency.
- Stripped `@default_` and `@valid_` prefixes from internal module attributes.
- Extracted `HTTP.Header` and `HTTP.Validator` into dedicated sub-modules.
- Split `Internet` helpers into `Internet.Generator` and `Internet.Validator` sub-modules.
- Split `Lorem` into `Lorem.Parser` and `Lorem.Validator` sub-modules.
- Removed duplicate private `hash_email!/1` from `Gravatar.Generator`.
- Renamed `Generator.ex` to `generator.ex` for consistent lowercase filenames.
- Added `@doc` attributes to all sub-module functions for improved autocomplete support.
- Bumped minimum Erlang to 28.0 and Elixir to 1.18.4-otp-28.
- Pinned development toolchain to Erlang 28.3 and Elixir 1.19.4-otp-28 in `mise.toml` and CI.
- Upgraded Hex dependencies.
- Updated module documentation: replaced "library" with "package", improved option descriptions, and added detailed examples.
- Added mise tasks and section comments to `mise.toml`.
- Renamed the "Available Locales" documentation page to "Locales".

### Bug Fixes

- Fixed issue where `NeoFaker.Address.city/0` could return `nil` for some locales.
- Resolved crash in `NeoFaker.Time.time_zone/0` when locale data is incomplete.
- Fixed validator bug surfaced during `Address` refactor.

### Tests

- Full refactor of all test modules to follow Elixir and ExUnit conventions.
- Fixed critical bug in `NeoFaker.Test` where a bare `assert` lived outside any `test` block inside a `describe`.
- Fixed wrong `describe` label `"decimal/2"` in `NeoFaker.NumberTest` — it was describing `Number.float/2`.
- Fixed wrong `describe` label `"words/1"` in `NeoFaker.LoremTest` — it was describing `Lorem.word/1`.
- Fixed wrong `describe` label `"add/0"` in `NeoFaker.TimeTest` — the function is `add/2`.
- Fixed incorrect assertion in `NeoFaker.PersonTest` for `short_binary_gender/1`: the result was checked against the full gender word list instead of the short single-character form.
- Fixed flaky race-condition tests in `NeoFaker.TimeTest` that compared live time snapshots with `==`; replaced with `%Time{}` struct checks, ISO 8601 format checks, and bounded range comparisons.
- Fixed redundant `String.ends_with?(...) or String.match?(...)` patterns in `NeoFaker.InternetTest`; the regex alone is sufficient.
- Moved `defp assert_semver/1` helper out of the `describe` block in `NeoFaker.AppTest` — private functions must be defined at module level; split into three clearly named helpers.
- Wrapped the lone `test "ipv4/0"` block (outside any `describe`) in `NeoFaker.InternetTest` into a proper `describe "ipv4/0"` block for consistency.
- Added `async: true` to `NeoFaker.AddressTest` which was missing it.
- Added `alias` for the module under test in every test file that was using fully-qualified calls.
- Replaced compound `assert a and b` assertions with separate `assert` calls throughout.
- Replaced `not String.starts_with?` with `refute String.starts_with?` in `NeoFaker.InternetTest`.
- Replaced `Enum.each(list, fn` with `for item <- list do` in test bodies (idiomatic ExUnit style).
- Added missing test coverage for `Number.positive/1`, `Number.negative/1`, `Number.decimal/3`, `Number.between/2` error cases, `get_locale/0`, `set_locale/1` error case, `HTTP.status_code/1` per-group simple codes, and `Gravatar.display/2` URL structure.
- Added format-correctness tests for `Crypto.md5/0`, `Crypto.sha1/0`, and `Crypto.sha256/0` (lowercase hex regex).
- Added format and bounds tests for `Date.add/2`, `Date.between/3`, and `Date.birthday/3`.
- Added NIK digits-only format check in `NeoFaker.IdId.PersonTest`.
- Split compound single-test assertions into focused individual tests across `en_us/person_test.exs` and `id_id/person_test.exs`.
- Improved test description wording to be precise and consistent across all test files.

## v0.13.0 (2025-10-29)

### Features

Added new module `NeoFaker.Internet` to handle internet-related data generation, including:

- `NeoFaker.Internet.tld/1` for generating random top-level domains (TLDs).
- `NeoFaker.Internet.username/1` for generating random usernames.
- `NeoFaker.Internet.domain_name/1` for generating random domain names.
- `NeoFaker.Internet.email/1` for generating random email addresses.
- `NeoFaker.Internet.ipv4/1` for generating random IPv4 addresses.
- `NeoFaker.Internet.ipv6/1` for generating random IPv6 addresses.
- `NeoFaker.Internet.mac_address/1` for generating random MAC addresses.
- `NeoFaker.Internet.url/1` for generating random URLs.
- `NeoFaker.Internet.slug/2` for generating random URL slugs.

### Improvements

- Changed `.tool-versions` to `mise.toml` for better version management, now NeoFaker uses mise
  as the version manager.
- Upgraded mix dependencies.
- Fixed typo in `cheat.cheatmd` file.
- Refactored `NeoFaker.Data.Cache` and `NeoFaker.Data.Disk` for improved file handling and caching
  mechanisms.

### Module Changes

**Breaking Changes**: Renamed `NeoFaker.Http` to `NeoFaker.HTTP` for consistency.

## v0.12.0 (2025-06-10)

### Features

- Added `NeoFaker.Address` for generating random address components: building numbers, cities, countries, and coordinates.
- Added `NeoFaker.Time.time_zone/0` for generating random time zones.

### Improvements

- Unified and clarified documentation for all public functions.
- Refactored generator modules: `NeoFaker.Data.Cache`, `NeoFaker.Data.Disk`,
  `NeoFaker.Data.Generator`, and `NeoFaker.Data.Resolver` for improved organization and
  readability.
- Updated `NeoFaker.Data.Cache.put_cache!/3` to use `Stream.uniq/1` for duplicate removal before
  caching.
- Upgraded mix dependencies.

**Breaking:** Renamed `NeoFaker.Internet` to `NeoFaker.HTTP` with expanded features.

#### `NeoFaker.http` (formerly `NeoFaker.Internet`)

- Added `Http.request_method/0` for random HTTP methods.
- Added `Http.referrer_policy/0` for random referrer policies.
- Added `Http.status_code/1` for random HTTP status codes with filtering.
- Enhanced `Http.user_agent/1` to support `:type` filtering (`:browser` or `:crawler`).

### Argument Standardization

**Breaking:** Default arguments now use explicit atoms:

- `NeoFaker.Color.hex/1` defaults to `:six_digit` (was `nil`).
- `NeoFaker.Color.keyword/1` defaults to `:all` (was `nil`).

### Organization & Locale

- Split large utility modules into smaller, focused modules.
- Improved documentation and examples.
- Added Indonesian locale support.
