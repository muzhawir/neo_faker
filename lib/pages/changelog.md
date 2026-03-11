# Changelog

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
