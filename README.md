<p align="center">
  <a href="https://hexdocs.pm/neo_faker" target="_blank">
    <img src="./lib/assets/logo/full_logo.svg" width="300" alt="NeoFaker Logo">
  </a>
</p>

# NeoFaker

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

**NeoFaker** is an Elixir library for generating fake data for testing and development.

## Installation

To install NeoFaker, follow the instructions in the [Getting Started Guide](https://hexdocs.pm/neo_faker/getting-started.html#installation).

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
