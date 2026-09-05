# Design-related anti-patterns

> Source: https://elixir.hexdocs.pm/1.20.4/design-anti-patterns.md
>
> Design-related anti-patterns concern modules, functions, and their roles
> in the codebase — decisions that usually require looking at a module's
> public API or how it's used across call sites, not just a single function
> body.

## 1. Alternative return types

**Problem**

A function whose options (typically a keyword list) can drastically change
its *return type* is hard to reason about, because options are optional and
sometimes computed dynamically — callers can't tell from the call site alone
what shape the result will have.

**Anti-pattern**

```elixir
defmodule AlternativeInteger do
  @spec parse(String.t(), keyword()) :: integer() | {integer(), String.t()} | :error
  def parse(string, options \\ []) when is_list(options) do
    if Keyword.get(options, :discard_rest, false) do
      case Integer.parse(string) do
        {int, _rest} -> int
        :error -> :error
      end
    else
      Integer.parse(string)
    end
  end
end
```

```elixir
iex> AlternativeInteger.parse("13")
{13, ""}
iex> AlternativeInteger.parse("13", discard_rest: false)
{13, ""}
iex> AlternativeInteger.parse("13", discard_rest: true)
13
```

**Refactored**

```elixir
defmodule AlternativeInteger do
  @spec parse(String.t()) :: {integer(), String.t()} | :error
  def parse(string) do
    Integer.parse(string)
  end

  @spec parse_discard_rest(String.t()) :: integer() | :error
  def parse_discard_rest(string) do
    case Integer.parse(string) do
      {int, _rest} -> int
      :error -> :error
    end
  end
end
```

```elixir
iex> AlternativeInteger.parse("13")
{13, ""}
iex> AlternativeInteger.parse_discard_rest("13")
13
```

Give each distinct return shape its own, separately named function instead
of branching the return type on an option.

**Detection heuristics**

- A function's `@spec` return type is a union of structurally different
  shapes (e.g. `integer() | {integer(), term()} | :error`) gated by an
  option.
- An option like `discard_rest:`, `raw:`, `format:` changes the *shape* of
  the return value rather than a detail within a fixed shape.

---

## 2. Boolean obsession

**Problem**

Using booleans instead of atoms (or richer composite types) to encode
information isn't wrong by itself, but once multiple booleans start
representing overlapping/mutually-exclusive states, replacing them with a
single atom (or tuple) is clearer and scales better.

**Anti-pattern**

```elixir
defmodule MyApp do
  def process(invoice, options \\ []) do
    cond do
      options[:admin] ->  # Is an admin
      options[:editor] -> # Is an editor
      true ->          # Is none
    end
  end
end
```

**Refactored**

```elixir
defmodule MyApp do
  def process(invoice, options \\ []) do
    case Keyword.get(options, :role, :default) do
      :admin ->   # Is an admin
      :editor ->  # Is an editor
      :default -> # Is none
    end
  end
end
```

**Additional remarks**

Prefer an atom-based option even for a single boolean flag when more states
might be added later. E.g. instead of `MyApp.update(invoice, approved: true)`,
prefer `MyApp.update(invoice, status: :approved)` — this reads better and
leaves room for future states (e.g. `:pending`) without an API break.
Booleans are internally atoms (`true`/`false`), so there's no performance
cost to choosing atoms over booleans.

**Detection heuristics**

- Two or more boolean options/fields on the same struct/function represent
  mutually exclusive states (only one can meaningfully be `true` at a time).
- A `cond`/`if` chain branches on several `options[:flag]` boolean lookups
  that are really one categorical choice.

---

## 3. Exceptions for control-flow

**Problem**

Using exceptions to drive control flow (instead of `case`/pattern matching)
makes error handling implicit and forces callers into `try/rescue`. Library
authors in particular should give callers a way to handle errors as data;
"exceptional" should mean genuinely unexpected, not "the normal-ish error
case I didn't want to model."

**Anti-pattern**

```elixir
defmodule MyModule do
  def print_file(file) do
    try do
      IO.puts(File.read!(file))
    rescue
      e -> IO.puts(:stderr, Exception.message(e))
    end
  end
end
```

```elixir
iex> MyModule.print_file("valid_file")
This is a valid file!
:ok
iex> MyModule.print_file("invalid_file")
could not read file "invalid_file": no such file or directory
:ok
```

**Refactored**

```elixir
defmodule MyModule do
  def print_file(file) do
    case File.read(file) do
      {:ok, binary} -> IO.puts(binary)
      {:error, reason} -> IO.puts(:stderr, "could not read file #{file}: #{reason}")
    end
  end
end
```

Use the non-bang API (`File.read/1`, which returns `{:ok, _} | {:error, _}`)
instead of `File.read!/1` + `rescue`. For reference, this is how the bang
variant itself is implemented — as a thin wrapper that raises on top of the
tuple-returning function:

```elixir
def read!(path) do
  case read(path) do
    {:ok, binary} ->
      binary

    {:error, reason} ->
      raise File.Error, reason: reason, action: "read file", path: IO.chardata_to_string(path)
  end
end
```

**Additional remarks**

This matters most for library authors and for any function invoked by other
developers' code. There are still legitimate cases for raising directly:
- **Invalid arguments** — structural errors, not semantic ones (e.g.
  `File.read(123)` should always raise, since `123` is never a valid
  filename).
- **Tests/scripts** — you often want to fail fast; `!` functions like
  `File.read!/1` give quick, clear failures.
- **Frameworks like Phoenix** let you raise in application code and convert
  the exception into a semantic HTTP response via a protocol — the framework
  owns turning "exceptional" into a controlled response.

**Detection heuristics**

- A `try/rescue` wraps a call to a `!`-suffixed function purely to branch on
  success/failure, where a non-bang, tuple-returning counterpart exists.
- A library's public API only exposes a raising function for a case that a
  caller would reasonably want to handle without a crash.

---

## 4. Primitive obsession

**Problem**

Excessive reliance on primitive types (integer, float, string) to carry
structured domain information, instead of introducing composite types
(tuples, maps, structs) that model the domain explicitly.

**Anti-pattern**

```elixir
defmodule MyApp do
  def extract_postal_code(address) when is_binary(address) do
    # Extract postal code with address...
  end

  def fill_in_country(address) when is_binary(address) do
    # Fill in missing country...
  end
end
```

**Refactored**

```elixir
defmodule Address do
  defstruct [:street, :city, :state, :postal_code, :country]
end

defmodule MyApp do
  def parse(address) when is_binary(address) do
    # Returns %Address{}
  end

  def extract_postal_code(%Address{} = address) do
    # Extract postal code with address...
  end

  def fill_in_country(%Address{} = address) do
    # Fill in missing country...
  end
end
```

Introduce a struct (here, `Address`) that models the domain, plus a
`parse/1` boundary function that converts the raw string into that struct
once. Downstream functions can then pattern-match on the struct and extract
fields directly instead of re-parsing a raw string repeatedly.

**Detection heuristics**

- Multiple functions accept the same "stringly typed" value and each
  re-parses/re-validates it independently.
- A raw string/integer is passed around and manipulated with string/number
  operations to extract what are really separate domain fields.

---

## 5. Unrelated multi-clause function

**Problem**

Multi-clause functions are powerful, but grouping genuinely unrelated
functionality under one function name/arity — where the behavior differs
qualitatively per input type — is an abuse of the feature. It muddies the
function's single `@doc` and makes its contract unclear.

**Anti-pattern**

```elixir
@doc """
Updates a struct.

If given a product, it will...

If given an animal, it will...
"""
def update(%Product{count: count, material: material})  do
  # ...
end

def update(%Animal{count: count, skin: skin})  do
  # ...
end
```

**Refactored**

```elixir
@doc """
Updates a product.

It will...
"""
def update_product(%Product{count: count, material: material}) do
  # ...
end

@doc """
Updates an animal.

It will...
"""
def update_animal(%Animal{count: count, skin: skin}) do
  # ...
end
```

Split the unrelated behaviors into separate, specifically named functions,
each with its own `@doc`. Multiple clauses are still fine *within* one of
these new functions as long as they all implement the *same* conceptual
operation:

```elixir
def update_product(%Product{count: 0}) do
  # ...
end

def update_product(%Product{material: material})
    when material in ["metal", "glass"] do
  # ...
end

def update_product(%Product{material: material})
    when material not in ["metal", "glass"] do
  # ...
end
```

Be careful: splitting a function like this can be a breaking change for
existing callers.

**Additional remarks**

The anti-pattern only applies when clauses behave *differently* depending on
input type. If a function behaves precisely the same way for any given
struct (e.g. a generic `struct/2` that treats every struct identically),
there's no ambiguity about behavior per input, so it is not this
anti-pattern.

**Detection heuristics**

- A function's `@doc` contains "if given X, ... if given Y, ..." branches
  describing qualitatively different behavior per clause.
- Clauses of the same function/arity pattern-match on unrelated struct
  types and do conceptually unrelated work.

---

## 6. Using application configuration for libraries

**Problem**

The application environment (`Application.get_env/2` etc.) is fine for
parameterizing an *application's* own global values, but it's an anti-pattern
for a *library* to read its own configuration from it. The application
environment is global per key/app, so two applications that both depend on
the same library can't configure that shared aspect of the library
differently — configuration collides.

**Anti-pattern**

Configuration:

```elixir
import Config

config :app_config,
  parts: 3

import_config "#{config_env()}.exs"
```

Library:

```elixir
defmodule DashSplitter do
  def split(string) when is_binary(string) do
    parts = Application.fetch_env!(:app_config, :parts) # <= retrieve parameterized value
    String.split(string, "-", parts: parts)             # <= parts: 3
  end
end
```

```elixir
iex> DashSplitter.split("Lucas-Francisco-Vegi")
["Lucas", "Francisco", "Vegi"]
iex> DashSplitter.split("Lucas-Francisco-da-Matta-Vegi")
["Lucas", "Francisco", "da-Matta-Vegi"]
```

**Refactored**

```elixir
defmodule DashSplitter do
  def split(string, opts \\ []) when is_binary(string) and is_list(opts) do
    parts = Keyword.get(opts, :parts, 2) # <= default config of parts == 2
    String.split(string, "-", parts: parts)
  end
end
```

```elixir
iex> DashSplitter.split("Lucas-Francisco-da-Matta-Vegi", [parts: 5])
["Lucas", "Francisco", "da", "Matta", "Vegi"]
iex> DashSplitter.split("Lucas-Francisco-da-Matta-Vegi") #<= default config is used!
["Lucas", "Francisco-da-Matta-Vegi"]
```

Take configuration as explicit function arguments (options/keyword lists)
so each caller can configure the library independently, with a sane
compiled-in default.

**Additional remarks — supervision trees**

If a library needs to start a supervision tree, don't make it read the
application environment for that either. Instead, provide a child
specification and let the *user* start it under their own supervisor,
passing custom options at that call site:

```elixir
children = [
  {DNSCluster, query: "my.subdomain"}
]
```

If per-environment configuration is still desired, it's the *user's*
responsibility to read the application environment themselves and pass it
in:

```elixir
children = [{DNSCluster, query: Application.get_env(:my_app, :dns_cluster_query) || :ignore}]
```

**Additional remarks — compile-time configuration**

For configuration a library needs at compile time, prefer letting users
generate the code themselves rather than forcing compile-time application
config. This is the approach `Ecto` takes:

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres
end
```

Instead of one global repo, users define as many `Ecto.Repo`s as they want,
and if they want the adapter to vary per environment, that's their choice to
make explicitly:

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo, adapter: Application.compile_env(:my_app, :repo_adapter)
end
```

Code generation itself comes with its own anti-patterns (see the macro
anti-patterns rules) and must be used carefully. In some cases — e.g. a
library that parses CSV/JSON files to generate code from data files —
reading from the application environment with reasonable defaults is
genuinely the best option, rather than asking every user to regenerate
identical code.

**Additional remarks — Mix tasks**

Mix tasks and related tools often need *per-project* configuration instead.
Rather than application environment, use `Mix.Project.config/0`, configured
directly in `mix.exs`:

```elixir
def project do
  [
    app: :my_app,
    version: "1.0.0",
    linter: [output_file: "/path/to/output.json", verbosity: 3],
    ...
  ]
end
```

If a Mix task is involved, also accept the same options as CLI arguments
(via `OptionParser`):

```
mix linter --output-file /path/to/output.json --verbosity 3
```

**Detection heuristics**

- A library module (not the top-level application) calls
  `Application.get_env/2,3` or `Application.fetch_env!/2` for a config key
  under its own `:otp_app`, to control ordinary runtime behavior instead of
  exposing that as a function argument/option.
- A library starts its own supervision tree from inside `Application.start/2`
  rather than exposing a child spec for the caller to place in their own tree.
- A `use MyLib, ...` macro reads `Application.compile_env/2,3` instead of
  accepting the value as an argument to `use`.
