# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

**NeoFaker** is an Elixir library that generates fake data for testing and development.

## Requirements

NeoFaker requires `Erlang 27.3` and `Elixir 1.18.3-otp-27` or later. We recommend using the
[asdf version manager](https://asdf-vm.com) to manage multiple Erlang and Elixir versions.

## Installation

Add NeoFaker to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.9.0", only: [:dev, :test]}
  ]
end
```

Then, fetch dependencies:

```sh
mix deps.get
```

## Configuration

Set the default locale in `config.exs`:

```elixir
config :neo_faker, locale: :default
```

If the specified locale is unavailable, it falls back to `:default`. A list of available locales
can be found on the [Available Locales](https://hexdocs.pm/neo_faker/available-locales.html) page.

## Usage

Generate fake data using NeoFaker:

```elixir
iex> NeoFaker.App.name()
"Neo Faker"

iex> NeoFaker.App.description()
"An Elixir library for generating fake data in tests and development."

iex> NeoFaker.App.description(locale: :id_id)
"Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."
```

For complete documentation, visit the [API Reference](https://hexdocs.pm/neo_faker/api-reference.html).
For a quick overview, check out the [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html).

## License

NeoFaker is licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
