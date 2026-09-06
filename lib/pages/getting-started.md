# Getting Started

[![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)](https://hex.pm/packages/neo_faker)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)](https://hex.pm/packages/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

NeoFaker is a fake data generator for Elixir tests and development environments.

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

Then fetch the dependency:

```sh
mix deps.get
```

## Configuration

Set the default locale in `config/config.exs`:

```elixir
config :neo_faker, locale: :default
```

If the requested locale is unavailable, NeoFaker falls back to `:default` (generic English US data).
See the [supported locales](https://hexdocs.pm/neo_faker/locales.html) for a full list.

`NeoFaker.set_locale/1` overrides the locale for the calling process only — it never touches
`config :neo_faker, locale: ...`, so other processes (including concurrent, `async: true` tests)
are unaffected. Use it for a quick script or a single test; use `config` for a locale that should
apply to the whole application.

### Phoenix Projects

For [Phoenix](https://hexdocs.pm/phoenix) apps, set the locale in `config/dev.exs` or
`config/test.exs` instead. In `test/test_helper.exs`, add:

```elixir
ExUnit.start()
NeoFaker.start()
```

If you use NeoFaker inside a `test/support/factory.ex` module to build fake `Ecto.Schema`
structs for your tests, see [Ecto Test Factories](ecto-integration.html) — it covers wiring
NeoFaker into the factory pattern from Ecto's own guide, and how to keep factory-generated values
unique where your schema requires it.

## Usage

Every function lives under a domain module such as `NeoFaker.Person`, `NeoFaker.Internet`, or
`NeoFaker.Date` — there is no single catch-all module:

```elixir
iex> NeoFaker.Person.full_name()
"Abigail Bethany Crawford"

iex> NeoFaker.Internet.email()
"josé@example.com"

iex> NeoFaker.App.description()
"Fake data generator for Elixir tests and development environments."

iex> NeoFaker.App.description(locale: :id_id)
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."
```

Most functions accept a keyword list of options to control the output shape — see each
function's own documentation for the options it supports:

```elixir
iex> NeoFaker.Date.past(30, format: :iso8601)
"2025-02-25"

iex> NeoFaker.Color.hex(format: :eight_digit)
"#613583FF"
```

## Reproducible output

NeoFaker draws values via `Enum.random/1` and `:rand.uniform/1`, both backed by `:rand`, which
Erlang/OTP seeds automatically and unpredictably per process. For deterministic output — for
example, snapshot-testing against a fixed value — seed it explicitly at the start of a test:

```elixir
setup do
  NeoFaker.seed(12_345)
end
```

## Next steps

- [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html) — a one-page reference of every
  function with examples, grouped by domain.
- [Supported Locales](https://hexdocs.pm/neo_faker/locales.html) — the list of available
  locales and how locale resolution works across processes, config, and per-call overrides.
- [Ecto Test Factories](https://hexdocs.pm/neo_faker/ecto-integration.html) — wiring NeoFaker
  into a `test/support/factory.ex` module for `Ecto.Schema`-based tests.
- [API Reference](https://hexdocs.pm/neo_faker/api-reference.html) — full module and function
  documentation.

## License

Licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
