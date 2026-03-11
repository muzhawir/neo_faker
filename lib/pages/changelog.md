# Changelog

## v0.14.0 (2026-03-11)

### Features

- Added `NeoFaker.Data.supported_locales/0` to expose the canonical list of supported locale atoms,
  cached in `:persistent_term` and sourced from `priv/data/locale.exs`.
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
- Added `NeoFaker.Internet.Generator.reserved_ipv4?/3` as a public predicate encoding all
  IANA-reserved ranges, usable independently of the generator.
- Added `NeoFaker.Helpers.Formatter` for standardized format conversions.
- Added `NeoFaker.Helpers.Options` for consistent option extraction and validation.
- Added `NeoFaker.IdId.Person.npwp/0` for generating random Indonesian tax identification numbers
  (NPWP), delegating to `nik/0`.
- Added `NeoFaker.Address.Generator` sub-module with `latitude/1` and `longitude/1` generators.
- Consolidated all data-access helpers into a unified `NeoFaker.Data` module.

### Improvements

- **`NeoFaker.Internet.Generator.public_ipv4/0`** — Completely overhauled to exclude all
  IANA-reserved ranges: `0.0.0.0/8`, `10.0.0.0/8`, `100.64.0.0/10` (CGN), `127.0.0.0/8`,
  `169.254.0.0/16`, `172.16.0.0/12`, `192.0.0.0/24`, `192.0.2.0/24`, `192.88.99.0/24`,
  `192.168.0.0/16`, `198.18.0.0/15`, `198.51.100.0/24`, `203.0.113.0/24`, `224.0.0.0/4`, and
  `240.0.0.0/4`. A compile-time cumulative weight table ensures first-octet selection is O(1).
- **`NeoFaker.Internet.Generator.url_path/0` and `query_string/0`** — Multi-word entries from
  `NeoFaker.Text.word/0` (e.g. `"ice cream"`) are now slugified (spaces replaced with `-`) before
  being joined into path segments or query-string keys.
- **`NeoFaker.Internet.url/1`** — Fixed double-TLD bug (e.g. `"gmail.com.net"`) for `:popular` and
  `:custom` domain types. TLD is now only appended for `:random` (word-based) domains.
- **`NeoFaker.set_locale/1`** — Now validates the supplied atom against
  `NeoFaker.Data.supported_locales/0` before storing it, and the error message dynamically lists
  all valid locale atoms.
- **`NeoFaker.Data`** — `@locale_file` now resolves via `:code.priv_dir(:neo_faker)`, fixing
  resolution when NeoFaker is used as a Mix dependency.
- **`NeoFaker.Crypto.token/2`** — Fixed guard that accidentally matched any integer to correctly
  raise `ArgumentError` only for non-positive lengths.
- **`NeoFaker.Number.decimal/3`** — Now delegates to `between/2` before rounding, inheriting its
  `min > max` validation.
- Extracted dedicated `Validator` and `Generator` sub-modules across all major modules: `Address`,
  `App`, `Blood`, `Boolean`, `Color`, `Crypto`, `Date`, `Gravatar`, `HTTP`, `Internet`, `Lorem`,
  `Number`, `Person`, `Text`, and `Time`.
- Removed `NeoFaker.Helpers.Constants` in favour of module attributes in each module.
- Extracted `HTTP.Header` and `HTTP.Validator`, `Internet.Generator` and `Internet.Validator`,
  `Lorem.Parser` and `Lorem.Validator` into dedicated sub-modules.
- Added `@doc` attributes to all sub-module functions for improved autocomplete support.
- Bumped minimum Erlang to 28.0 and Elixir to 1.18.4-otp-28. Pinned dev toolchain to Erlang 28.3
  and Elixir 1.19.4-otp-28 in `mise.toml` and CI.
- Renamed the "Available Locales" documentation page to "Locales".

### Bug Fixes

- `NeoFaker.App.bundle_id/1` and `App.package_name/1` no longer raise `MatchError` on domains
  that contain no dot or are empty; a clear `ArgumentError` is raised instead.
- `NeoFaker.Internet.ipv4/1` no longer raises `FunctionClauseError` for unsupported `:class`
  values; `ArgumentError` is raised with a descriptive message.
- `NeoFaker.Internet.Generator.public_ipv4/0` previously could generate loopback, private,
  link-local, multicast, CGN, and various test/documentation ranges. All IANA-reserved ranges are
  now excluded.
- Fixed off-by-one bug in `find_octet_in_table/2` cumulative table lookup.
- Fixed issue where `NeoFaker.Address.city/0` could return `nil` for some locales.
- Fixed `NeoFaker.Date.birthday/3` start date calculation.
- Resolved crash in `NeoFaker.Time.time_zone/0` when locale data is incomplete.
- Scoped `:persistent_term` cache keys to tuples to prevent cross-module key collisions.
- Added path-traversal validation on data file names in `NeoFaker.Data`.

### Breaking Changes

- **`NeoFaker.set_locale/1`** now raises `ArgumentError` for atoms not present in
  `priv/data/locale.exs` (or `:default`). Use `NeoFaker.Data.supported_locales/0` to enumerate
  valid values.
- **`NeoFaker.Internet.ipv4/0`** (public mode) no longer returns any IANA-reserved address.
  Callers that relied on receiving reserved ranges must switch to `ipv4(private: true)`.

### Tests

- Added exhaustive `NeoFaker.GravatarTest` coverage: size validation, fallback atoms and URL
  strings, `:rating` and `:force_default` parameters, `profile/2` formats, `random/0`, and all
  introspection helpers.
- Replaced probabilistic IPv4 reserved-range sampling with deterministic boundary assertions
  against `reserved_ipv4?/3`, covering every IANA block at both endpoints and adjacent public
  addresses. Class-specific private IPv4 tests now also validate full four-octet structure.
- Added `NeoFaker.AppTest` coverage for `bundle_id/1` and `package_name/1` domain validation
  error paths.
- Added `NeoFaker.CryptoTest` coverage for `token/2` length error paths and hash format checks.
- Added `NeoFaker.NumberTest` coverage for `decimal/3` inverted-range error, bounds, and
  precision; `between/2` mixed-type float generation.
- Added `NeoFakerTest` coverage for `set_locale/1` valid and invalid inputs.
- Full refactor of all test modules to follow Elixir and ExUnit conventions: `async: true`,
  `alias` for modules under test, `refute` instead of `not assert`, `for` instead of
  `Enum.each`, separate assertions instead of compound `assert a and b`.

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
