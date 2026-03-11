# Changelog

## v0.14.0 (2026-03-11)

### Features

- Added `NeoFaker.Data.supported_locales/0` — returns the supported locale atoms from
  `priv/data/locale.exs`, cached in `:persistent_term`.
- Added `NeoFaker.Gravatar.profile/2` — generates a Gravatar profile URL with `:format` option
  (`:html`, `:json`, `:xml`, `:php`, `:vcf`, `:qr`).
- Added `NeoFaker.Gravatar.random/0` — generates a Gravatar image URL with a random size and
  fallback type.
- Added `NeoFaker.Gravatar.fallback_types/0`, `default_size/0`, and `size_range/0` as public
  introspection helpers.
- Added `NeoFaker.Gravatar.display/2` options `:rating` (`:g`, `:pg`, `:r`, `:x`) and
  `:force_default` (appends `&f=y` when `true`).
- Added `NeoFaker.App.Validator.validate_domain!/1` — raises `ArgumentError` on invalid domain
  strings, replacing silent `MatchError` in `bundle_id/1` and `package_name/1`.
- Added `NeoFaker.Internet.Validator.validate_ipv4_class!/1` — raises `ArgumentError` on invalid
  `:class` values in `ipv4/1`, replacing `FunctionClauseError`.
- Added `NeoFaker.Internet.Generator.reserved_ipv4?/3` — public predicate for all IANA-reserved
  IPv4 ranges, usable independently of the generator.
- Added `NeoFaker.Helpers.Formatter` for format conversions and `NeoFaker.Helpers.Options` for
  option extraction and validation.
- Added `NeoFaker.IdId.Person.npwp/0` for generating Indonesian tax identification numbers (NPWP).
- Added `NeoFaker.Address.Generator` with `latitude/1` and `longitude/1`.
- Consolidated all data-access helpers into `NeoFaker.Data`.

### Improvements

- **`public_ipv4/0`** — Now excludes all IANA-reserved ranges: `0.0.0.0/8`, `10.0.0.0/8`,
  `100.64.0.0/10`, `127.0.0.0/8`, `169.254.0.0/16`, `172.16.0.0/12`, `192.0.0.0/24`,
  `192.0.2.0/24`, `192.88.99.0/24`, `192.168.0.0/16`, `198.18.0.0/15`, `198.51.100.0/24`,
  `203.0.113.0/24`, `224.0.0.0/4`, and `240.0.0.0/4`. First-octet selection uses a compile-time
  cumulative weight table for O(1) performance.
- **`url_path/0` and `query_string/0`** — Multi-word entries from `Text.word/0` (e.g.
  `"ice cream"`) are slugified (spaces → `-`) before use in path segments and query keys.
- **`url/1`** — Fixed double-TLD output (e.g. `"gmail.com.net"`) for `:popular` and `:custom`
  domain types; TLD is now only appended for `:random` domains.
- **`set_locale/1`** — Validates the locale against `supported_locales/0` before storing; the
  error message lists all valid values.
- **`NeoFaker.Data`** — Locale file now resolved via `:code.priv_dir/1`, fixing lookup when
  NeoFaker is used as a Mix dependency.
- **`Crypto.token/2`** — Fixed guard that incorrectly matched any integer; `ArgumentError` is
  now raised only for non-positive lengths.
- **`Number.decimal/3`** — Delegates to `between/2` before rounding, inheriting `min > max`
  validation.
- Extracted `Validator` and `Generator` sub-modules across all major modules: `Address`, `App`,
  `Blood`, `Boolean`, `Color`, `Crypto`, `Date`, `Gravatar`, `HTTP`, `Internet`, `Lorem`,
  `Number`, `Person`, `Text`, and `Time`.
- Removed `NeoFaker.Helpers.Constants` in favour of module attributes.
- Added `@doc` to all sub-module functions for improved autocomplete.
- Bumped minimum Erlang/OTP to 28.0 and Elixir to 1.18.4. Pinned dev toolchain to OTP 28.3 and
  Elixir 1.19.4 in `mise.toml` and CI.
- Renamed the "Available Locales" docs page to "Locales".

### Bug Fixes

- `bundle_id/1` and `package_name/1` now raise `ArgumentError` (not `MatchError`) for domains
  with no dot or empty strings.
- `ipv4/1` now raises `ArgumentError` (not `FunctionClauseError`) for unsupported `:class` values.
- `public_ipv4/0` no longer generates loopback, private, link-local, multicast, CGN, or
  test/documentation addresses.
- Fixed off-by-one in `find_octet_in_table/2` cumulative weight lookup.
- Fixed `Address.city/0` returning `nil` for some locales.
- Fixed `Date.birthday/3` start date calculation.
- Fixed crash in `Time.time_zone/0` when locale data is incomplete.
- Scoped `:persistent_term` cache keys to tuples to prevent cross-module collisions.
- Added path-traversal validation on data file names in `NeoFaker.Data`.
- `domain_name/1` with `type: :custom` now raises `ArgumentError` for a non-string or empty
  `:domain_name`, preventing bad values from propagating into `email/1` and `url/1`.
- `validate_domain!/1` now enforces RFC 1123 label rules — alphanumeric start/end, letters,
  digits, and hyphens only, max 63 chars per label. Rejects trailing dots, `/`, `:`, and
  leading/trailing hyphens.
- `locale/0` now raises `ArgumentError` for unsupported atoms stored directly in the application
  env, preventing `get_locale/0` from reporting a different locale than generators actually use.
- `Number.decimal/3` now raises `ArgumentError` for negative precision (was `FunctionClauseError`).
  The `@spec` is widened to `number()` to reflect that integer bounds are accepted.

### Breaking Changes

- **`set_locale/1`** raises `ArgumentError` for any atom not in `priv/data/locale.exs` (or
  `:default`). Use `NeoFaker.Data.supported_locales/0` to list valid values.
- **`ipv4/0`** (public mode) no longer returns IANA-reserved addresses. Use `ipv4(private: true)`
  if you need a private range address.

### Tests

- Added comprehensive `GravatarTest` coverage: size, fallback types, `:rating`, `:force_default`,
  `profile/2` formats, `random/0`, and all introspection helpers.
- Replaced probabilistic IPv4 sampling with deterministic boundary assertions against
  `reserved_ipv4?/3`, covering all IANA blocks at both endpoints and adjacent public addresses.
  Class-specific private IPv4 tests also verify full four-octet structure.
- Added `AppTest` error-path coverage for `bundle_id/1` and `package_name/1` domain validation.
- Added `CryptoTest` coverage for `token/2` length errors and hash format checks.
- Added `NumberTest` coverage for `decimal/3` range errors, bounds, precision, and mixed-type
  float generation in `between/2`.
- Added `NeoFakerTest` coverage for `set_locale/1` and `locale/0` valid and invalid inputs.
- Refactored all test modules to follow ExUnit conventions: `async: true`, module aliases,
  `refute` over `not assert`, `for` over `Enum.each`, separate assertions over compound `assert`.

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
