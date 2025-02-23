# Changelog for v0.7

## v0.7.0 (2025-02-23)

### Introduced `:locale` option in functions

Functions that retrieve data from locale data files now support an optional `:locale` option.
This allows specifying a locale other than the default one defined in `config.exs`.

For example, if the default locale in `config.exs` is `"default"`, but you need to use the `"id_id"`
locale in a specific function call, you can do the following:

```elixir
iex> NeoFaker.App.name(locale: "id_id")
"Elixir library untuk menghasilkan fake data dalam pengujian dan pengembangan."
```

### Introduced new generator functions and options

#### `NeoFaker.Person`

- `NeoFaker.Person.first_name/1`
- `NeoFaker.Person.middle_name/1`
- `NeoFaker.Person.last_name/1`

#### `NeoFaker.Boolean`

- `NeoFaker.Boolean.boolean/2` now supports an optional `integer: true` option to return `1` or `0`
instead of `true` or `false`.

### Updated documentation

- Added [Available Locales](available-locales.html) page to provide a list of supported locales.
- Added [Contributing](contributing.html) page to guide contributors.

### Major refactorings

- Refactored the entire codebase to use `NeoFaker` instead of `Nf` for improved readability.
- Removed multiple results in generator functions.
