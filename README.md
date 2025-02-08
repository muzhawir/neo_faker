<p align="center">
  <a href="https://hexdocs.pm/neo_faker" target="_blank">
    <img src="./priv/logo/full_logo.svg" width="300" alt="NeoFaker Logo">
  </a>
</p>

# NeoFaker

![Hex.pm Version](https://img.shields.io/hexpm/v/neo_faker) ![Hex.pm Downloads](https://img.shields.io/hexpm/dt/neo_faker)

> [!WARNING]
> **This project is still in early development.** Expect breaking changes!.

**NeoFaker** is a fake data generator for Elixir, useful for testing, database seeding, and development.

## Installation

Add `neo_faker` to your list of dependencies in `mix.exs` to install it from [Hex](https://hex.pm/packages/neo_faker):

```elixir
def deps do
  [
    {:neo_faker, "~> 0.4.0", only: [:dev, :test], runtime: false}
  ]
end
```
