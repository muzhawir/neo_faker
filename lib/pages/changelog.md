# Changelog

## v0.12.0 (2025-06-10)

### Features

- Introduced `NeoFaker.Address` for generating random address components: building numbers, cities, countries, and coordinates.
- Added `NeoFaker.Time.time_zone/0` for random time zone generation.

### Improvements

- Unified and clarified documentation for all public functions.
- Refactored generator modules: `NeoFaker.Data.Cache`, `NeoFaker.Data.Disk`, `NeoFaker.Data.Generator`, and `NeoFaker.Data.Resolver` for better organization and readability.
- Updated `NeoFaker.Data.Cache.put_cache!/3` to use `Stream.uniq/1` for duplicate removal before caching.
- Upgraded mix dependencies.

## v0.11.0 (2025-05-05)

### Module Changes

**Breaking:** Renamed `NeoFaker.Internet` to `NeoFaker.HTTP` with expanded features.

#### `NeoFaker.HTTP` (formerly `NeoFaker.Internet`)

- Added `request_method/0` for random HTTP methods.
- Added `referrer_policy/0` for random referrer policies.
- Added `status_code/1` for random HTTP status codes with filtering.
- Enhanced `user_agent/1` to support `:type` filtering (`:browser` or `:crawler`).

### Argument Standardization

**Breaking:** Default arguments now use explicit atoms:

- `NeoFaker.Color.hex/1` defaults to `:six_digit` (was `nil`).
- `NeoFaker.Color.keyword/1` defaults to `:all` (was `nil`).

### Organization & Locale

- Split large utility modules into smaller, focused modules.
- Improved documentation and examples.
- Added Indonesian locale support.
