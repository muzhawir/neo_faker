# Getting Started

[![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker)](https://hex.pm/packages/neo_faker)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)](https://hex.pm/packages/neo_faker)
[![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

NeoFaker is a fake data generator for Elixir tests and development environments.

## Requirements

- **Erlang**: `27.0` or newer
- **Elixir**: `1.18.0-otp-27` or newer

## Installation

Add NeoFaker to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.13.0", only: [:dev, :test]}
  ]
end
```

Install the dependency:

```sh
mix deps.get
```

## Configuration

Set the default locale in your `config.exs`:

```elixir
config :neo_faker, locale: :default
```

If the locale is unavailable, NeoFaker falls back to `:default`. See the
[list of supported locales](https://hexdocs.pm/neo_faker/available-locales.html).

> ### Phoenix Projects {: .tip}
>
> For [Phoenix](https://hexdocs.pm/phoenix) apps, set the locale in `config/dev.exs` or `config/test.exs`.
>
> In `test/test_helper.exs`, add:
>
> ```elixir
> ExUnit.start()
> NeoFaker.start()
> ```

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
