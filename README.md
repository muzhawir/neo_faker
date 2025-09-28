<p align="center">
  <a href="https://hexdocs.pm/neo_faker" target="_blank">
    <img src="./priv/assets/logo/full_logo.svg" width="300" alt="NeoFaker Logo">
  </a>
</p>

# NeoFaker

[![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)](https://hex.pm/packages/neo_faker)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)](https://hex.pm/packages/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

NeoFaker is a fake data generator for Elixir tests and development environments.

## Requirements

- **Erlang**: `27.0` or newer
- **Elixir**: `1.18.0-otp-27` or newer

## Installation

See the [Getting Started Guide](https://hexdocs.pm/neo_faker/getting-started.html) for installation instructions.

## Usage

Generate fake data with NeoFaker:

```elixir
iex> NeoFaker.App.name()
"Neo Faker"

iex> NeoFaker.App.description()
"Fake data generator for Elixir tests and development environments."

iex> NeoFaker.App.description(locale: :id_id)
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."
```

For detailed documentation, see the [API Reference](https://hexdocs.pm/neo_faker/api-reference.html).
For a quick overview, see the [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html).

## License

Licensed under the [MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
