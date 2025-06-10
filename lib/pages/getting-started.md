# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

Fake data generator for Elixir tests and development environments.

## Requirements

To use NeoFaker, your environment must meet the following requirements:

- **Erlang**: Version `27.0` or later
- **Elixir**: Version `1.18.0-otp-27` or later

## Installation

Add NeoFaker to the dependencies in your `mix.exs` file:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.12.0", only: [:dev, :test]}
  ]
end
```

Fetch the dependencies by running:

```sh
mix deps.get
```

## Configuration

Set the default locale in the `config.exs` file:

```elixir
config :neo_faker, locale: :default
```

If the specified locale is not available, NeoFaker will use the `:default` locale. A list of
supported locales is available on the
[Available Locales](https://hexdocs.pm/neo_faker/available-locales.html) page.

> ### Setting Configuration in Phoenix {: .tip}
>
> In a [Phoenix Framework](https://hexdocs.pm/phoenix) project, set the locale in `config/dev.exs`
> or `config/test.exs`.
>
> Add the following line to `test/test_helper.exs`:
>
> ```elixir
> ExUnit.start()
> NeoFaker.start() # Add this line
> ```

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

For detailed documentation, visit the
[API Reference](https://hexdocs.pm/neo_faker/api-reference.html). For a quick overview, refer to
the [Cheat Sheet](https://hexdocs.pm/neo_faker/cheat.html).

## License

NeoFaker is licensed under the
[MIT License](https://github.com/muzhawir/neo_faker/blob/main/LICENSE.md).
