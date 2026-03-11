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
- Bumped minimum Erlang to 28.3 and Elixir to 1.19.4-otp-28.
- Upgraded Hex dependencies.
- Updated module documentation: replaced "library" with "package", improved option descriptions, and added detailed examples.
- Added mise tasks and section comments to `mise.toml`.
- Renamed the "Available Locales" documentation page to "Locales".

### Bug Fixes

- Fixed issue where `NeoFaker.Address.city/0` could return `nil` for some locales.
- Resolved crash in `NeoFaker.Time.time_zone/0` when locale data is incomplete.
- Fixed validator bug surfaced during `Address` refactor.

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
