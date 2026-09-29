# Getting Started

NeoFaker generates realistic fake data for Elixir tests, database seeds, and local
development. This guide covers installation, configuration, and the conventions every
generator follows.

## Requirements

- Elixir 1.18 or newer
- Erlang/OTP 27 or newer

## Installation

Add `:neo_faker` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.15.0", only: [:dev, :test]}
  ]
end
```

Then fetch it:

```sh
mix deps.get
```

Restricting the dependency to `:dev` and `:test` keeps fake data out of production builds. If
you seed a staging database from a release, drop the `only:` option.

## First steps

Generators are grouped by domain, one module each. There is no catch-all module:

```elixir
iex> NeoFaker.Person.full_name()
"Abigail Bethany Crawford"

iex> NeoFaker.Internet.email()
"abigail.crawford@kappa.com"

iex> NeoFaker.Date.birthday()
~D[1991-07-14]

iex> NeoFaker.Crypto.uuid()
"550e8400-e29b-41d4-a716-446655440000"
```

A few conventions hold across the library:

  * **Options are keyword lists.** Functions that can shape their output accept options, such
    as `NeoFaker.Color.hex(format: :eight_digit)` or `NeoFaker.Person.first_name(sex: :female)`.
    An unknown option or an invalid value raises `NimbleOptions.ValidationError`.
  * **Positional arguments are bounds and counts.** Ranges, minimums, maximums, and counts are
    positional, as in `NeoFaker.Person.age(18, 65)` or `NeoFaker.Lorem.words(5)`. An invalid
    value raises `ArgumentError`.
  * **Plural functions return lists.** `NeoFaker.Lorem.sentences/2` and
    `NeoFaker.Text.words/1` return a list; use `Enum.join/2` if you need a single string.
  * **Dates and times are structs.** `NeoFaker.Date` returns `Date` structs and `NeoFaker.Time`
    returns `Time` structs, ready to assign to Ecto fields.

## Configuration

NeoFaker works without any configuration, using the `:default` data set (US English). To
generate data for another locale by default, set it in your config:

```elixir
# config/config.exs
config :neo_faker, locale: :id_id
```

If the dependency is limited to `:dev` and `:test`, as above, put this line in
`config/dev.exs` and `config/test.exs` instead, the environments where NeoFaker is available.

The locale can also be changed for the current process with `NeoFaker.Locale.set/1`, or for a
single call with the `:locale` option. See [Locales](locales.html) for how these interact.

### Test suites

Optionally, call `NeoFaker.start/0` in `test/test_helper.exs`:

```elixir
ExUnit.start()
NeoFaker.start()
```

It starts the application and validates the configured locale, so a typo in
`config :neo_faker, locale: ...` fails the test run immediately instead of on the first
generator call.

## Reproducible output

Every generator draws from `:rand`, which the VM seeds randomly for each process. To make a
test generate the same values on every run, seed it:

```elixir
setup do
  NeoFaker.seed(12_345)
end
```

Seeding affects only the calling process. `NeoFaker.Crypto.token/2` is the one exception: it
always uses cryptographically strong random bytes, which cannot be seeded.

## Next steps

  * [Locales](locales.html): supported locales and how the active locale is resolved.
  * [Ecto Test Factories](ecto-integration.html): using NeoFaker in an Ecto factory module.
  * [Cheatsheet](cheat.html) and [Locale Cheatsheet](locale-cheat.html): every generator on
    one page.
  * [Adding a Locale](adding-a-locale.html): how to contribute a new locale.
