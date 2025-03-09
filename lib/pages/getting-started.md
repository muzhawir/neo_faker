# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

**NeoFaker** is an Elixir library for generating fake data for testing and development.

## Installation

Add NeoFaker to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.8.0", only: [:dev, :test]}
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
config :neo_faker, locale: "default"
```

If the specified locale is unavailable, it falls back to `"default"`. A list of available locales
can be found on the [Available Locales](https://hexdocs.pm/neo_faker/available-locales.html) page.

## Usage

```elixir
iex> NeoFaker.App.name()
"Neo Faker"

iex> NeoFaker.App.description()
"An Elixir library for generating fake data in tests and development."

iex> NeoFaker.App.description(locale: "id_id")
"Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."
```

For full documentation, check the [API Reference](https://hexdocs.pm/neo_faker/api-reference.html).
For a quick guide, see the [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html).

## License

NeoFaker is licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
