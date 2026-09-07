# Code-related anti-patterns

> Source: https://elixir.hexdocs.pm/1.20.4/code-anti-patterns.md
>
> Code-related anti-patterns concern language idioms and low-level code
> constructs — things you'd notice reading a single function or module,
> independent of the broader system design.

## 1. Comments overuse

**Problem**

Overusing comments, or commenting self-explanatory code, makes code *less*
readable, not more. Elixir has first-class, built-in support for
documentation (`@doc`, `@moduledoc`, doctests) which is a different concept
from code comments — comments should be reserved for things documentation
can't express (rationale, warnings, non-obvious trade-offs), not for
restating what the code already says.

**Anti-pattern**

```elixir
# Returns the Unix timestamp of 5 minutes from the current time
defp unix_five_min_from_now do
  # Get the current time
  now = DateTime.utc_now()

  # Convert it to a Unix timestamp
  unix_now = DateTime.to_unix(now, :second)

  # Add five minutes in seconds
  unix_now + (60 * 5)
end
```

**Refactored**

```elixir
@five_min_in_seconds 60 * 5

defp unix_five_min_from_now do
  now = DateTime.utc_now()
  unix_now = DateTime.to_unix(now, :second)
  unix_now + @five_min_in_seconds
end
```

Use descriptive function/variable names and named module attributes for
"magic" values instead of narrating each line.

**Detection heuristics**

- A comment restates exactly what the next line of code does.
- A comment explains what a well-named function/variable already conveys.
- A block of comments could be replaced by extracting a well-named private
  function or module attribute.

---

## 2. Complex `else` clauses in `with`

**Problem**

A `with` expression that funnels every clause's error into a single, flat
`else` block is hard to read and maintain, because it's not obvious from the
`else` block alone which `<-` clause produced which error value.

**Anti-pattern**

```elixir
def open_decoded_file(path) do
  with {:ok, encoded} <- File.read(path),
       {:ok, decoded} <- Base.decode64(encoded) do
    {:ok, String.trim(decoded)}
  else
    {:error, _} -> {:error, :badfile}
    :error -> {:error, :badencoding}
  end
end
```

**Refactored**

```elixir
def open_decoded_file(path) do
  with {:ok, encoded} <- file_read(path),
       {:ok, decoded} <- base_decode64(encoded) do
    {:ok, String.trim(decoded)}
  end
end

defp file_read(path) do
  case File.read(path) do
    {:ok, contents} -> {:ok, contents}
    {:error, _} -> {:error, :badfile}
  end
end

defp base_decode64(contents) do
  case Base.decode64(contents) do
    {:ok, decoded} -> {:ok, decoded}
    :error -> {:error, :badencoding}
  end
end
```

Normalize each step's return type in its own private function (`case`-based),
so `with` only ever needs its happy-path clauses and no `else` at all. Errors
are handled right where they originate.

**Detection heuristics**

- A `with` has an `else` block matching two or more unrelated error shapes.
- The `else` block mixes error tuples that came from different `<-` steps.

---

## 3. Complex extractions in clauses

**Problem**

Multi-clause functions can extract values in their head for pattern
matching/guards. When a function extracts values across *several clauses and
several arguments*, it becomes hard to tell which extracted bindings are
actually used for matching/guards and which are only used in the function
body.

**Anti-pattern**

```elixir
def drive(%User{name: name, age: age}) when age >= 18 do
  "#{name} can drive"
end

def drive(%User{name: name, age: age}) when age < 18 do
  "#{name} cannot drive"
end
```

**Refactored**

```elixir
def drive(%User{age: age} = user) when age >= 18 do
  %User{name: name} = user
  "#{name} can drive"
end

def drive(%User{age: age} = user) when age < 18 do
  %User{name: name} = user
  "#{name} cannot drive"
end
```

In the function head, extract only the fields needed for the pattern/guard.
Bind the whole struct/term with `= user` and destructure whatever else is
needed inside the body.

**Detection heuristics**

- A multi-clause function's head extracts fields that are never referenced in
  a guard and are only used in the body.
- The same struct/map fields are re-extracted identically across many
  clauses purely for body use, not for matching.

---

## 4. Dynamic atom creation

**Problem**

Atoms are not garbage collected and the VM has a hard limit on how many can
exist. Creating atoms dynamically from unbounded/external input (e.g.
request payloads) is dangerous because the developer has no control over how
many distinct atoms get created, risking unexpected memory growth or hitting
the atom table limit — a potential DoS vector when the input comes from
outside the system.

**Anti-pattern**

```elixir
defmodule MyRequestHandler do
  def parse(%{"status" => status, "message" => message} = _payload) do
    %{status: String.to_atom(status), message: message}
  end
end
```

**Refactored — explicit mapping**

```elixir
defmodule MyRequestHandler do
  def parse(%{"status" => status, "message" => message} = _payload) do
    %{status: convert_status(status), message: message}
  end

  defp convert_status("ok"), do: :ok
  defp convert_status("error"), do: :error
  defp convert_status("redirect"), do: :redirect
end
```

**Refactored — `String.to_existing_atom/1`**

```elixir
defmodule MyRequestHandler do
  def parse(%{"status" => status, "message" => message} = _payload) do
    %{status: String.to_existing_atom(status), message: message}
  end

  def valid_statuses do
    [:ok, :error, :redirect]
  end
end
```

Either map known strings to atoms explicitly, or use
`String.to_existing_atom/1` (which raises instead of creating a new atom) so
only a bounded, pre-known set of atoms can ever be produced.

**Detection heuristics**

- `String.to_atom/1`, `List.to_atom/1`, or `:erlang.binary_to_atom/1,2`
  applied to a value that originates from user/network/file input.
- Any dynamic atom creation inside a loop over external data.

---

## 5. Long parameter list

**Problem**

As a function's responsibilities grow, so can its argument count, until the
call interface becomes confusing and error-prone to use correctly (e.g. easy
to swap two same-typed positional arguments).

**Anti-pattern**

```elixir
defmodule Library do
  # Too many parameters that can be grouped!
  def loan(user_name, email, password, user_alias, book_title, book_ed) do
    ...
  end
end
```

**Refactored**

```elixir
defmodule Library do
  def loan(%{name: name, email: email, password: password, alias: alias} = user, %{title: title, ed: ed} = book) do
    ...
  end
end
```

Group related positional arguments into maps, structs, or keyword lists.
This shrinks the parameter count and makes call sites self-describing.

**Detection heuristics**

- A function signature has many (roughly 5+) positional parameters, several
  of which are conceptually related (belong to the same entity).
- Callers commonly pass several arguments of the same primitive type
  (multiple strings/integers in a row), risking argument-order mistakes.

---

## 6. Namespace trespassing

**Problem**

A package/library defining modules outside its own "namespace" (i.e. not
prefixed by the library's own name) risks colliding with modules from other
libraries, since the Erlang VM can only load one instance of a given module
name at a time — two unrelated libraries defining the same module name
become mutually incompatible.

**Anti-pattern**

```elixir
defmodule Plug.Auth do
  # ...
end
```

*(defined by a library that is not `plug` itself)*

**Refactored**

```elixir
defmodule PlugAuth do
  # ...
end
```

**Additional remarks**

Known exceptions:
- Protocol implementations are, by design, defined under the protocol's
  namespace (e.g. `Enumerable.MyStruct`).
- The namespace owner may explicitly grant another library permission to
  define modules under its namespace — but that owner is then responsible for
  avoiding/managing future conflicts.

**Detection heuristics**

- A library's `mix.exs` `:app` name doesn't match (as a prefix of) the
  top-level module names it defines, and it isn't a protocol implementation
  or an explicitly sanctioned exception.

---

## 7. Non-assertive map access

**Problem**

When a key is expected to always exist in a map, access it with `map.key` —
this fails loudly (raises) if the key is missing, which is what you want.
Using `map[:key]` for a key that's supposed to always be present silently
returns `nil` if it's unexpectedly absent, letting `nil` propagate through
the system instead of failing fast where the bug actually is.

**Anti-pattern**

```elixir
defmodule Graphics do
  def plot(point) do
    # Some other code...
    {point[:x], point[:y], point[:z]}
  end
end
```

**Refactored — mix static/dynamic access**

```elixir
defmodule Graphics do
  def plot(point) do
    # Some other code...
    {point.x, point.y, point[:z]}
  end
end
```

**Refactored — pattern matching**

```elixir
defmodule Graphics do
  # 3d
  def plot(%{x: x, y: y, z: z}) do
    # Some other code...
    {x, y, z}
  end

  # 2d
  def plot(%{x: x, y: y}) do
    # Some other code...
    {x, y}
  end
end
```

**Refactored — structs**

```elixir
defmodule Point2D do
  @enforce_keys [:x, :y]
  defstruct [x: nil, y: nil]
end
```

Use `map.key` for keys that must exist, and reserve `map[:key]` for keys
that are genuinely optional. Pattern matching in the function head validates
required keys at the same time it extracts them. Structs with
`@enforce_keys` enforce required fields at compile/construction time.

**Detection heuristics**

- `map[:key]` used for a key the surrounding code assumes is always present
  (no subsequent `nil` handling).
- A `nil` bug traced back to a missing key that silently returned `nil`
  instead of raising.

---

## 8. Non-assertive pattern matching

**Problem**

Writing defensive/imprecise code that can return values nobody planned for,
instead of using assertive pattern matching/guards that crash loudly on
unexpected shapes. Hiding malformed input behind soft fallbacks conceals bugs
instead of surfacing them.

**Anti-pattern**

```elixir
defmodule Extract do
  def get_value(string, desired_key) do
    parts = String.split(string, "&")

    Enum.find_value(parts, fn pair ->
      key_value = String.split(pair, "=")
      Enum.at(key_value, 0) == desired_key && Enum.at(key_value, 1)
    end)
  end
end
```

**Refactored**

```elixir
defmodule Extract do
  def get_value(string, desired_key) do
    parts = String.split(string, "&")

    Enum.find_value(parts, fn pair ->
      [key, value] = String.split(pair, "=")
      key == desired_key && value
    end)
  end
end
```

Pattern-match on the exact expected shape (`[key, value] = ...`) so
malformed input crashes immediately instead of silently misbehaving
(`Enum.at/2` returning `nil` for missing indices).

**Additional remarks**

`case/2` is another key construct for writing assertive code by matching
specific patterns. Avoid a catch-all `_ ->` branch when the set of expected
outcomes is known — matching only on `_` hides bugs if the matched function
later starts returning new values you didn't anticipate.

**Detection heuristics**

- `Enum.at/2`, `List.first/1`, `Map.get/2` (with a fallback) used on data
  whose shape/arity is supposed to be fixed and already validated elsewhere.
- A `case` whose only "failure" branch is a bare `_ ->`, throwing away
  information about what didn't match.

---

## 9. Non-assertive truthiness

**Problem**

`&&/2`, `||/2`, and `!/1` work with truthiness (accepting non-boolean
operands), whereas `and/2`, `or/2`, and `not/1` require boolean operands and
raise otherwise. Using the truthy versions when *all* operands are actually
expected to be booleans hides type mistakes instead of catching them.

**Anti-pattern**

```elixir
if is_binary(name) && is_integer(age) do
  # ...
else
  # ...
end
```

**Refactored**

```elixir
if is_binary(name) and is_integer(age) do
  # ...
else
  # ...
end
```

**Additional remarks**

This is especially relevant when interfacing with Erlang code: Erlang has no
concept of truthiness. Erlang functions never return `nil`; they return
values like `:error` or `:undefined` instead, which would be truthy under
`&&`/`||` even though they are meant to signal failure.

**Detection heuristics**

- `&&`, `||`, or `!` used where every operand is a boolean-returning
  expression (e.g. `is_*` guards, comparisons) — should be `and`/`or`/`not`.
- `&&`/`||` used directly on the result of an Erlang call that can return
  `:error`/`:undefined`.

---

## 10. Structs with 32 fields or more

**Problem**

The Erlang VM represents small maps (up to 32 keys) as flat, optimized
structures. Once a struct reaches 32 or more fields, it loses this
optimization, which can increase memory usage and degrade the performance of
several struct operations (pattern matching, updates).

**Anti-pattern**

```elixir
defmodule MyExample do
  defstruct [
    :field1,
    :field2,
    ...,
    :field35
  ]
end
```

**Refactoring**

Keep structs under 32 fields by:
- nesting optional/rarely-used fields into a metadata sub-map/sub-struct,
- nesting related fields into their own struct and referencing it,
- or grouping related scalar fields into tuples.

**Additional remarks**

Structs of the same name "instantiated" in the same module share the same
internal representation at compile time, as long as they have fewer than 32
fields — this optimization stops applying once a struct reaches 32+ fields.
Balance this against API ergonomics: don't over-fragment a struct just to
dodge the number if it hurts usability more than it helps memory.

**Detection heuristics**

- `defstruct` (or a corresponding typespec/schema) declares 32 or more
  fields.
- A struct's field count is close to 32 and still growing — flag for
  attention before it crosses the line.
