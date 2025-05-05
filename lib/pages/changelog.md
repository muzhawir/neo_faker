# Changelog for v0.11

## v0.11.0 (2025-05-05)

### Module Rename

[BREAKING CHANGES] This release renames the `NeoFaker.Internet` module to `NeoFaker.Http` with
enhanced functionality.

#### `NeoFaker.Http` (previously `NeoFaker.Internet`)

- Added `NeoFaker.Http.request_method/0` - Generates a random HTTP request method.
- Added `NeoFaker.Http.referrer_policy/0` - Generates a random HTTP referrer policy.
- Added `NeoFaker.Http.status_code/1` - Generates a random HTTP status code with optional
  filtering.
- Enhanced `NeoFaker.Http.user_agent/1` - Now accepts a `:type` option to filter by `:browser` or
  `:crawler`.

### Standardized Default Arguments

[BREAKING CHANGES] Several functions now use explicit atoms instead of `nil` for default
arguments:

- `NeoFaker.Color.hex/1` - Now defaults to `:six_digit` format instead of `nil`.
- `NeoFaker.Color.keyword/1` - Now uses `:all` instead of `nil` for the default category.

### Code Organization

- Improved module organization by moving function implementations from large utility modules to
  smaller, focused modules.
- Enhanced documentation and examples throughout the codebase.
- Added Indonesian locale support for various generators.
