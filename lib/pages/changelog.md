# Changelog for v0.9

## v0.9.0 (2025-03-31)

### BREAKING CHANGES

This release introduces breaking changes as the library is still under heavy development. The locale configuration and option values now use `Atom` instead of `String`.

#### Changes in `config.exs`

```elixir
# Before
config :neo_faker, :default_locale, "en_us"

# After
config :neo_faker, :default_locale, :en_us
```

#### Changes in function options

```elixir
# Before
iex> NeoFaker.App.description(locale: "id_id")
"Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."

# After
iex> NeoFaker.App.description(locale: :id_id)
"Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."
```

### Refactor Locale Data Map Values

The function `NeoFaker.Helper.Locale.read_locale_file!/3` has been refactored to return a map with
shuffled values, increasing randomness in the generated output.

### New Locale Generators

This release introduces new locale-specific generators.

#### `NeoFaker.IdId.Person`

The `NeoFaker.IdId.Person` module provides functions for generating person-related data specific to the Indonesian locale. Currently, it includes the `nik/0` function.

#### `NeoFaker.EnUs.Person`

Similar to `NeoFaker.IdId.Person`, but for the EN-US locale. At this stage, it includes only the `ssn/0` function.

### New Date, Time, and DateTime Generators

This release also introduces new generators for date, time, and datetime.

#### `NeoFaker.Date`

- `NeoFaker.Date.add/2` - Generates a random date within a specified range.
