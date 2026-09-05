# Process-related anti-patterns

> Source: https://elixir.hexdocs.pm/1.20.4/process-anti-patterns.md
>
> Process-related anti-patterns concern processes (`GenServer`, `Agent`,
> `Task`, raw `spawn`, etc.) and process-based abstractions. A process
> should model a genuine *runtime* property (concurrency, shared mutable
> state, fault isolation, ...) — reaching for one for any other reason tends
> to create these anti-patterns.

## 1. Code organization by process

**Problem**

A process is not, by itself, a code-organization tool. Wrapping ordinary,
sequential logic in a `GenServer`/`Agent` purely to "namespace" it turns
every call into a message send, serializing all access through that one
process and creating an avoidable bottleneck — even when the underlying
computation has no need for concurrency or shared state.

**Anti-pattern**

```elixir
defmodule Calculator do
  @moduledoc """
  Calculator that performs basic arithmetic operations.

  This code is unnecessarily organized in a GenServer process.
  """

  use GenServer

  def add(a, b, pid) do
    GenServer.call(pid, {:add, a, b})
  end

  def subtract(a, b, pid) do
    GenServer.call(pid, {:subtract, a, b})
  end

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl GenServer
  def handle_call({:add, a, b}, _from, state) do
    {:reply, a + b, state}
  end

  def handle_call({:subtract, a, b}, _from, state) do
    {:reply, a - b, state}
  end
end
```

```elixir
iex> {:ok, pid} = GenServer.start_link(Calculator, :init)
{:ok, #PID<0.132.0>}
iex> Calculator.add(1, 5, pid)
6
iex> Calculator.subtract(2, 3, pid)
-1
```

**Refactored**

```elixir
defmodule Calculator do
  def add(a, b) do
    a + b
  end

  def subtract(a, b) do
    a - b
  end
end
```

```elixir
iex> Calculator.add(1, 5)
6
iex> Calculator.subtract(2, 3)
-1
```

Organize plain code with modules and functions only. A library in
particular should not impose a concurrency/parallelization model on its
users — let the *caller* decide whether/how to run code concurrently
(`Task`, etc.), which keeps the library reusable in more contexts.

**Detection heuristics**

- A `GenServer`/`Agent` whose `handle_call`/`handle_cast` bodies are pure
  computations with no reference to `state` (or state is just a
  pass-through), and no concurrent/shared-resource requirement motivates the
  process.
- A module wraps stateless functions in a process purely so callers do
  `GenServer.call(pid, ...)` instead of `Module.fun(...)`.

---

## 2. Scattered process interfaces

*(formerly known as "Agent obsession")*

**Problem**

Using `Agent`, `GenServer`, or another process abstraction is not itself an
anti-pattern. But when the responsibility for talking to a given process
directly (calling `Agent.update/2`, `Agent.get/2`, etc.) is spread across
many unrelated modules, the process's "protocol" — what shapes of data it
holds and how it's mutated — is defined nowhere in particular, is hard to
maintain, and is prone to bugs (e.g. two call sites disagreeing on the data
shape).

**Anti-pattern**

```elixir
defmodule A do
  def update(process) do
    # Some other code...
    Agent.update(process, fn _list -> 123 end)
  end
end

defmodule B do
  def update(process) do
    # Some other code...
    Agent.update(process, fn content -> %{a: content} end)
  end
end

defmodule C do
  def update(process) do
    # Some other code...
    Agent.update(process, fn content -> [:atom_value | content] end)
  end
end

defmodule D do
  def get(process) do
    # Some other code...
    Agent.get(process, fn content -> content end)
  end
end
```

```elixir
# start an agent with initial state of an empty list
iex> {:ok, agent} = Agent.start_link(fn -> [] end)
{:ok, #PID<0.135.0>}

# many data formats (for example, List, Map, Integer, Atom) are
# combined through direct access spread across the entire system
iex> A.update(agent)
iex> B.update(agent)
iex> C.update(agent)

# state of shared information
iex> D.get(agent)
[:atom_value, %{a: 123}]
```

**Refactored**

```elixir
defmodule Foo.Bucket do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end
```

```elixir
# start an agent through `Foo.Bucket`
iex> {:ok, bucket} = Foo.Bucket.start_link(%{})
{:ok, #PID<0.114.0>}

# add shared values to the keys `milk` and `beer`
iex> Foo.Bucket.put(bucket, "milk", 3)
iex> Foo.Bucket.put(bucket, "beer", 7)

# access shared data of specific keys
iex> Foo.Bucket.get(bucket, "beer")
7
iex> Foo.Bucket.get(bucket, "milk")
3
```

Centralize *all* direct interaction with a given process abstraction inside
one dedicated module. That module owns and documents the accepted data
shape, eliminates duplicated access code, and is the only place that needs
to change if the underlying representation changes.

**Detection heuristics**

- Multiple, unrelated modules call `Agent.update/2,3`, `Agent.get/2,3`,
  `GenServer.call/2,3`, or `GenServer.cast/2` directly on the *same* process,
  each assuming a possibly different state shape.
- No single module owns the "API" for a given process; callers reach into
  it with ad hoc anonymous functions instead of named functions.

---

## 3. Sending unnecessary data

**Problem**

Sending a message to a process (`send/2`, `GenServer.call/3`,
`GenServer.start_link/3`'s init data, `spawn/1`, `Task.async/1`,
`Task.async_stream/3`, ...) copies that message into the receiving process's
memory (Erlang's "share nothing" process model, which is what makes GC
simple and fast per-process). A large message is therefore CPU/memory
expensive to send. This is subtle with `spawn`/`Task.async` and similar,
because the closure captures *every* variable it references — all of which
get copied — so it's easy to accidentally ship far more data into a process
than the work inside it actually needs.

**Anti-pattern**

```elixir
# log_request_ip send the ip to some external service
spawn(fn -> log_request_ip(conn) end)
```

```elixir
GenServer.cast(pid, {:report_ip_address, conn})
```

**Refactored**

```elixir
ip_address = conn.remote_ip
spawn(fn -> log_request_ip(ip_address) end)
```

```elixir
GenServer.cast(pid, {:report_ip_address, conn.remote_ip})
```

**Refactoring options**

- Limit what you send to the absolute minimum needed — don't ship an entire
  struct (like a full `conn`) when only a couple of its fields matter.
- If only the receiving process needs certain data, consider having *that*
  process fetch the data itself instead of the caller passing it in.
- For data that changes infrequently, consider a shared-storage mechanism
  like `:persistent_term` instead of message passing.

**Detection heuristics**

- `spawn/1`, `Task.async/1`, `Task.async_stream/3`, `send/2`,
  `GenServer.call/cast` closures/messages that reference a large struct
  (e.g. a `Plug.Conn`, an Ecto struct with preloads) when only 1-2 fields of
  it are used inside.
- A message/init argument carries a whole aggregate when the receiving
  process only reads a small, fixed subset of it.

---

## 4. Unsupervised processes

**Problem**

Spawning a process outside of a supervision tree isn't wrong in isolation,
but spawning many *long-running* processes this way makes them invisible to
supervision: no consistent startup/shutdown ordering, no automatic restart
policy, and no single place to observe/monitor them, leaving their lifecycle
effectively out of the application's control.

**Anti-pattern**

```elixir
defmodule Counter do
  @moduledoc """
  Global counter implemented as an Agent.
  """

  use Agent

  @doc "Starts a counter process."
  def start_link(opts \\ []) do
    initial_state = Keyword.get(opts, :initial_value, 0)
    name = Keyword.get(opts, :name, __MODULE__)
    Agent.start_link(fn -> initial_state end, name: name)
  end

  @doc "Gets the current value of the given counter."
  def get(name \\ __MODULE__) do
    Agent.get(name, fn state -> state end)
  end

  @doc "Bumps the value of the given counter."
  def bump(name \\ __MODULE__, value) do
    Agent.get_and_update(fn state -> {state, value + state} end)
  end
end
```

```elixir
iex> Counter.start_link()
{:ok, #PID<0.115.0>}
iex> Counter.bump(13)
0
iex> Counter.get()
13
```

*(`start_link/1` here is called ad hoc, not placed under any supervisor.)*

**Refactored**

```elixir
defmodule SupervisedProcess.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # With the default values for counter and name
      Counter,
      # With custom values for counter, name, and a custom ID
      Supervisor.child_spec(
        {Counter, name: :other_counter, initial_value: 15},
        id: :other_counter
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: App.Supervisor)
  end
end
```

Start every long-running process inside a supervision tree. Supervisors
give deterministic startup order, guaranteed reverse-order shutdown (so you
can clean up reliably), and configurable restart strategies for handling
unexpected failures — none of which a bare `start_link/1` call gets you.

**Detection heuristics**

- `Agent.start_link/1,2`, `GenServer.start_link/2,3`, `Task.start_link/1`,
  or `spawn_link/1` invoked directly (e.g. in a controller, a one-off
  script path, or lazily on first use) rather than listed as a child of an
  `Application`/`Supervisor`.
- A long-lived process whose crash would go unnoticed because nothing
  supervises or restarts it.
