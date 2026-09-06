<p align="center">
  <a href="https://hexdocs.pm/neo_faker" target="_blank">
    <img src="./priv/assets/logo/full_logo.svg" width="300" alt="NeoFaker Logo">
  </a>
</p>

# NeoFaker

[![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)](https://hex.pm/packages/neo_faker)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)](https://hex.pm/packages/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

NeoFaker generates realistic-looking fake data for Elixir tests, database seeds, and local
development, including names, addresses, dates, email addresses, colors, cryptographic values,
and more, with built-in locale support.

## Features

- **15 data domains.** `Address`, `App`, `Blood`, `Boolean`, `Color`, `Crypto`, `Date`,
  `Gravatar`, `HTTP`, `Internet`, `Lorem`, `Number`, `Person`, `Text`, and `Time`.
- **Locale-aware.** Generate data for a specific locale (currently `:en_us` and `:id_id`) per
  call, per process, or for the whole application. See [Supported Locales](https://hexdocs.pm/neo_faker/locales.html).
- **Locale-exclusive generators.** Country-specific formats that don't apply universally, such
  as US Social Security Numbers and Indonesian NIK/NPWP numbers.
- **Validated options.** Every function validates its options and raises `ArgumentError` with a
  precise message on invalid input, instead of failing silently or deep inside a helper.
- **Reproducible output.** Seed the random number generator once to get deterministic values
  across a test run.

## Requirements

- **Erlang**: `28.0` or newer
- **Elixir**: `1.18.4-otp-28` or newer

## Installation

Add NeoFaker to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.15.0", only: [:dev, :test]}
  ]
end
```

Then fetch it:

```sh
mix deps.get
```

See the [Getting Started Guide](https://hexdocs.pm/neo_faker/getting-started.html) for the full
setup walkthrough, including test-suite configuration.

## Configuration

Set a default locale in `config/config.exs`:

```elixir
config :neo_faker, locale: :default
```

If the requested locale is unavailable, NeoFaker falls back to `:default` (generic English (US)
data). `NeoFaker.set_locale/1` overrides the locale for the calling process only, which makes it
safe to use inside `async: true` tests without affecting other processes.

### Using with Phoenix

For a Phoenix app, set the locale in `config/dev.exs` and `config/test.exs` instead of the
top-level `config.exs`, and call `NeoFaker.start()` in `test/test_helper.exs`. If you also use
NeoFaker inside `test/support/factory.ex` to build fake `Ecto.Schema` structs for your tests, see
the [Ecto Test Factories](https://hexdocs.pm/neo_faker/ecto-integration.html) guide, which covers
wiring NeoFaker into the factory pattern from Ecto's own docs, plus how to keep factory-generated
values unique where your schema requires it.

## Usage

```elixir
iex> NeoFaker.Person.full_name()
"Abigail Bethany Crawford"

iex> NeoFaker.Internet.email()
"josé@example.com"

iex> NeoFaker.Address.city(locale: :id_id)
"Palu"

iex> NeoFaker.Date.past(30)
~D[2025-02-25]

iex> NeoFaker.Color.hex()
"#613583"
```

## Documentation

| Guide                                                                     | Covers                                                                |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [Getting Started](https://hexdocs.pm/neo_faker/getting-started.html)      | Installation, configuration, first steps                             |
| [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html)                    | One-page reference of every domain generator function with examples  |
| [Locale Cheat Sheet](https://hexdocs.pm/neo_faker/locale-cheat.html)      | One-page reference of locale-exclusive generators, grouped by locale |
| [Supported Locales](https://hexdocs.pm/neo_faker/locales.html)            | Available locales and how locale resolution works                    |
| [Ecto Test Factories](https://hexdocs.pm/neo_faker/ecto-integration.html) | Using NeoFaker as the data source in an Ecto-based factory module    |
| [Adding a Locale](https://hexdocs.pm/neo_faker/adding-a-locale.html)      | Contributor guide for submitting a new locale as a pull request      |
| [API Reference](https://hexdocs.pm/neo_faker/api-reference.html)          | Full module and function documentation                               |
| [Changelog](https://hexdocs.pm/neo_faker/changelog.html)                  | Release history                                                      |

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/muzhawir/neo_faker).

## License

Licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
