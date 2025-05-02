# Getting Started

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker) [![Elixir CI](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml/badge.svg)](https://github.com/muzhawir/neo_faker/actions/workflows/build.yml)

**NeoFaker** is an Elixir library that generates fake data for testing and development.

## Requirements

NeoFaker requires `Erlang 27.0` and `Elixir 1.18.0-otp-27` or later.

## Installation

Add NeoFaker to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.10.0", only: [:dev, :test]}
  ]
end
```

Then, fetch the dependencies:

```sh
mix deps.get
```

## Configuration

Set the default locale in `config.exs`:

```elixir
config :neo_faker, locale: :default
```

If the specified locale is unavailable, it will fall back to `:default`.
You can find the list of available locales on the [Available Locales](https://hexdocs.pm/neo_faker/available-locales.html) page.

> ### Setting Configuration in Phoenix {: .tip}
>
> In [Phoenix Framework](https://hexdocs.pm/phoenix), set the locale in `config/dev.exs` or
> `config/test.exs`.
>
> Then add `NeoFaker.start()` to `test/test_helper.exs`:
>
> ```elixir
> ExUnit.start()
> NeoFaker.start() # Add this line
> ```

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
