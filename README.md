<p align="center">
  <a href="https://hexdocs.pm/neo_faker" target="_blank">
    <img src="./priv/assets/logo/full_logo.svg" width="300" alt="NeoFaker Logo">
  </a>
</p>

# NeoFaker

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

Fake data generator for Elixir tests and development environments.

## Requirements

To use NeoFaker, your environment must meet the following requirements:

- **Erlang**: Version `27.0` or later
- **Elixir**: Version `1.18.0-otp-27` or later

## Installation

To install NeoFaker, follow the instructions in the [Getting Started Guide](https://hexdocs.pm/neo_faker/getting-started.html).

## Usage

NeoFaker provides functions to generate fake data. Examples:

```elixir
iex> NeoFaker.App.name()
"Neo Faker"

iex> NeoFaker.App.description()
"Fake data generator for Elixir tests and development environments."

iex> NeoFaker.App.description(locale: :id_id)
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."
```

For detailed documentation, visit the [API Reference](https://hexdocs.pm/neo_faker/api-reference.html).
For a quick overview, refer to the [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html).

## License

NeoFaker is licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
