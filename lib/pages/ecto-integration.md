# Ecto Test Factories

Ecto's own guide, [Test factories](https://ecto.hexdocs.pm/test-factories.html), starts from
this premise:

> Many projects depend on external libraries to build their test data. Some of those libraries
> are called factories because they provide convenience functions for producing different
> groups of data. However, given Ecto is able to manage complex data trees, we can implement
> such functionality without relying on third-party projects.

The guide has you write a `test/support/factory.ex` module by hand: a `build/1` clause per
schema, `build/2` to override fields, and `insert!/2` to persist through your `Repo`.

NeoFaker is not a factory library in that sense. It has no knowledge of `Ecto.Schema`, builds no
structs, and never touches a `Repo`. Its scope is narrower: given a field, produce a
realistic-looking value for it — a name, an email, a date, a UUID. It belongs to the same
category as Ruby's `Faker` or JavaScript's `Faker.js`, and it slots into the `build/1` clauses
Ecto's guide has you write, rather than replacing them.

## Usage

Nothing about the factory's shape changes. NeoFaker only replaces the right-hand side of each
field:

```elixir
defmodule MyApp.Factory do
  alias MyApp.Repo

  def build(:user) do
    %MyApp.User{
      email: NeoFaker.Internet.email(),
      username: NeoFaker.Internet.username(),
      full_name: NeoFaker.Person.full_name()
    }
  end

  def build(:post) do
    %MyApp.Post{
      title: NeoFaker.Lorem.sentence(),
      body: NeoFaker.Lorem.paragraphs(3, join: true),
      inserted_at: NeoFaker.Date.past(30)
    }
  end

  def build(:post_with_comments) do
    %MyApp.Post{
      title: NeoFaker.Lorem.sentence(),
      comments: [
        build(:comment),
        build(:comment)
      ]
    }
  end

  def build(:comment) do
    %MyApp.Comment{body: NeoFaker.Lorem.sentence()}
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
```

`build(:post)`, `build(:post, title: "custom title")`, and `insert!(:post)` all behave exactly as
described in Ecto's guide — only the values come from NeoFaker instead of being hardcoded.

Ecto's own examples use fixed placeholders, such as `title: "hello world"`. That is enough to
illustrate the pattern, but every generated record ends up with the same shape, so edge cases in
formatting, length, or encoding never surface in a real test suite. NeoFaker addresses that by
returning a different, realistic value on each call, across more domains than are worth writing
by hand: `NeoFaker.Person`, `NeoFaker.Address`, `NeoFaker.Date`, `NeoFaker.Time`,
`NeoFaker.Internet`, `NeoFaker.Lorem`, `NeoFaker.Color`, `NeoFaker.Crypto`, and more. See the
[Cheat Sheet](cheat.html) for the full list.

## Generating unique values

NeoFaker guarantees realism, not uniqueness. It draws from a finite, locale-specific dataset
(see [Supported Locales](locales.html)), so `NeoFaker.Person.first_name()` can return the same
value on two separate calls — it keeps no record of what it has already returned.

Ecto already has a complete answer for uniqueness, and NeoFaker is not part of it: a
`unique_index` enforces it at the database, and `Ecto.Changeset.unique_constraint/3` turns a
violation into an ordinary changeset error. `System.unique_integer/1`, which Ecto's guide uses
for factory emails and usernames, sits at a different layer — it keeps test data from colliding
with itself by accident, rather than enforcing anything. Keep using it for that, and use
NeoFaker only for the part of the value that does not need to be unique:

```elixir
def build(:user) do
  %MyApp.User{
    email: "#{NeoFaker.Internet.username()}+#{System.unique_integer([:positive])}@example.com",
    full_name: NeoFaker.Person.full_name()
  }
end
```

`NeoFaker.Internet.username/1` and `NeoFaker.Internet.email/1` accept a `number: true` option
that appends a random suffix. That lowers the odds of a collision for quick scripts or seed
data, but the suffix is still random, not unique — use `System.unique_integer/1` wherever a
value must not collide.

## Setup

Add NeoFaker as a dev/test-only dependency:

```elixir
def deps do
  [
    {:neo_faker, "~> 0.15.0", only: [:dev, :test]}
  ]
end
```

If the factory module lives under `test/support/`, that directory must be compiled in the
`:test` environment. This is required for the factory pattern itself, independent of NeoFaker:

```elixir
defp elixirc_paths(:test), do: ["lib", "test/support"]
defp elixirc_paths(_), do: ["lib"]
```

Set a default locale for tests in `config/test.exs` (see
[Getting Started](getting-started.html#configuration) for the full configuration guide,
including notes for Phoenix projects):

```elixir
config :neo_faker, locale: :default
```
