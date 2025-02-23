# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

**NeoFaker** is an Elixir package for generating fake data for testing and development.

## Installation

NeoFaker is available on [Hex](https://hex.pm/packages/neo_faker). Add it to your dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.7.0", only: [:dev, :test]}
  ]
end
```

Then, fetch the dependencies:

```sh
mix deps.get
```

## Configuration

The default locale is `"default"`, but it can be changed in `config.exs`:

```elixir
config :neo_faker, locale: "default"
```

If the specified locale is not found, it will fall back to `"default"`.

A list of available locales can be found on the [Available Locales](available-locales.html) page.

## Usage

Here are some examples of how to use NeoFaker:

```elixir
iex> NeoFaker.App.name()
"Neo Faker"

iex> NeoFaker.App.description()
"An Elixir library for generating fake data in tests and development."
```

For a complete list of available modules, refer to the [API Reference](api-reference.html).
For a summarized guide, see the [Cheat Sheet](cheat.html).

## License

NeoFaker is licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
