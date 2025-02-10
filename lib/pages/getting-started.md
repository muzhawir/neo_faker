# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)
![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/muzhawir/neo_faker/actions/workflows/elixir.yml)

**NeoFaker** is an Elixir package for generating fake data for testing and development.

> #### Warning {: .warning}
>
> This project is still in early development. Expect breaking changes.

## Installation

Add `:neo_faker` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.5.1", only: [:dev, :test], runtime: false}
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
iex> Nf.App.name()
"Neo Faker"

iex> Nf.App.description()
"Elixir library for generating fake data in tests and development."
```

For a complete list of available functions, check out the [API Reference](api-reference.html).


## License

NeoFaker is licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
