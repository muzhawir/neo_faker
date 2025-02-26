# Changelog for v0.7

## v0.7.1 (2025-02-24)

### Documentation Improvements

Refactored all module and function documentation for better clarity and consistency.

## **v0.7.0 (2025-02-23)**

### New Feature: `:locale` Option

Functions that retrieve data from locale files now support an optional `:locale` option, this
allows overriding the default locale set in `config.exs`.

#### **Example Usage:**

If the default locale in `config.exs` is `"default"`, but you need to use `"id_id"` in a specific
function call:

```elixir
iex> NeoFaker.App.name(locale: "id_id")
"Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."
```

### New Generator Functions and Options

#### `NeoFaker.Person`

- Added `NeoFaker.Person.first_name/1`
- Added `NeoFaker.Person.middle_name/1`
- Added `NeoFaker.Person.last_name/1`
- Added `NeoFaker.Person.full_name/1`

#### `NeoFaker.Boolean`

`NeoFaker.Boolean.boolean/2` now supports an optional `integer: true` option to return `1` or `0`
instead of `true` or `false`.

### Documentation Updates

- Added [Available Locales](available-locales.html) page listing supported locales.
- Updated [Cheat Sheet](cheat.html) page with new functions and options.

### Major Refactoring

- Standardized all module references, replacing `Nf` with `NeoFaker` for improved readability.
- Removed support for multiple return values in generator functions.
