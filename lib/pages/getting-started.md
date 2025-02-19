# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)
![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

**NeoFaker** is an Elixir package for generating fake data for testing and development.

> #### Warning {: .warning}
>
> This project is still in early development. Expect breaking changes.

## Installation

Add `:neo_faker` to your dependencies in `mix.exs`:

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

## Usage

Here are some examples of how to use NeoFaker:

```elixir
iex> NeoFaker.App.name()
"Neo Faker"

iex> NeoFaker.App.description()
"Elixir library for generating fake data in tests and development."
```

For a complete list of available functions, check out the [API Reference](api-reference.html).
If you're looking for a quick reference, see the [Cheat Sheet](cheat.html).

## License

NeoFaker is licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
