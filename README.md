<p align="center">
  <a href="https://hexdocs.pm/neo_faker" target="_blank">
    <img src="./priv/assets/logo/full_logo.svg" width="300" alt="NeoFaker Logo">
  </a>
</p>

# NeoFaker

[![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)](https://hex.pm/packages/neo_faker)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)](https://hex.pm/packages/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

NeoFaker generates realistic fake data for Elixir tests, database seeds, and local development.

- **Broad coverage**: people, addresses, internet identifiers, dates and times, colors, hashes,
  HTTP values, placeholder text, and more, one module per domain.
- **Locale-aware**: localized data sets, selectable per call, per process, or for the whole
  application.
- **Safe in concurrent tests**: locale overrides are scoped to the calling process, so
  `async: true` tests never interfere with each other.
- **Reproducible**: `NeoFaker.seed/1` makes a process generate the same values on every run.

## Requirements

- Elixir 1.18 or newer
- Erlang/OTP 27 or newer

## Installation

Add `:neo_faker` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.16.0", only: [:dev, :test]}
  ]
end
```

Then run `mix deps.get`.

## Usage

```elixir
iex> NeoFaker.Person.full_name()
"Abigail Bethany Crawford"

iex> NeoFaker.Internet.email()
"abigail.crawford@kappa.com"

iex> NeoFaker.Address.city(locale: :id_id)
"Palu"

iex> NeoFaker.Date.past(30)
~D[2025-02-25]

iex> NeoFaker.Color.hex()
"#613583"
```

Functions accept a keyword list of options where the output can be shaped, for example
`NeoFaker.Crypto.uuid(format: :compact)` or `NeoFaker.Person.full_name(sex: :female)`. Each
function documents its options.

## Configuration

Every locale-aware generator uses the `:default` data set (US English) unless told otherwise.
To change the default for the whole application, set it in your config:

```elixir
# config/test.exs
config :neo_faker, locale: :id_id
```

To change it for the current process only, call `NeoFaker.Locale.set/1`. To change it for a
single call, pass the `:locale` option. See the
[Locales guide](https://hexdocs.pm/neo_faker/locales.html) for details.

## Documentation

- [Getting Started](https://hexdocs.pm/neo_faker/getting-started.html): installation,
  configuration, and first steps.
- [Locales](https://hexdocs.pm/neo_faker/locales.html): supported locales and how the active
  locale is resolved.
- [Ecto Test Factories](https://hexdocs.pm/neo_faker/ecto-integration.html): using NeoFaker in
  an Ecto factory module.
- [Cheatsheet](https://hexdocs.pm/neo_faker/cheat.html) and
  [Locale Cheatsheet](https://hexdocs.pm/neo_faker/locale-cheat.html): every generator on one page.
- [API Reference](https://hexdocs.pm/neo_faker/api-reference.html): full module and function
  documentation.
- [Adding a Locale](https://hexdocs.pm/neo_faker/adding-a-locale.html): how to contribute a new
  locale.
- [Changelog](https://hexdocs.pm/neo_faker/changelog.html): release history.

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/muzhawir/neo_faker). To add
a locale, follow the [Adding a Locale](https://hexdocs.pm/neo_faker/adding-a-locale.html) guide.

Before opening a pull request, run the same checks as CI:

```sh
mix format --check-formatted
mix credo --strict
mix docs.cheatsheet --check
mix test --cover
mix dialyzer
```

## License

NeoFaker is released under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
