# Macro-related anti-patterns

> Source: https://elixir.hexdocs.pm/1.20.4/macro-anti-patterns.html
>
> Macro-related anti-patterns concern meta-programming: `defmacro`, `quote`,
> `unquote`, `use`/`__using__`, and other compile-time code generation.
> These matter most in libraries and framework-style code that other
> projects depend on and compile against.

## 1. Compile-time dependencies

**Problem**

Any use of a macro adds a compile-time dependency from the calling module to
the module that defines the macro. If a macro's arguments (e.g. a module
name) also become compile-time dependencies — for instance because the
macro inspects/expands them at compile time — this can produce sprawling
dependency graphs where touching a single file forces many unrelated files
to recompile.

**Anti-pattern**

```elixir
defmodule Plug.Builder do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :plugs, accumulate: true)
      @before_compile Plug.Builder
    end
  end

  defmacro plug(mod) do
    quote do
      @plugs unquote(mod)
    end
  end
end
```

**Refactored**

```elixir
defmacro plug(mod) do
  mod = Macro.expand_literals(mod, %{__CALLER__ | function: {:call, 2}})

  quote do
    @plugs unquote(mod)
  end
end
```

When a macro doesn't actually need to introspect a module argument's
metadata at compile time, use `Macro.expand_literals/2` to expand module
references within their real execution context ahead of time, turning what
would otherwise be a compile-time dependency into a runtime-only one.

**Detection heuristics**

- A macro accepts a module name as an argument and stores/uses it in ways
  that force the caller to recompile whenever *that* module changes, even
  though the macro never actually needs compile-time information about it.
- Editing one file in the project triggers a surprisingly large recompilation
  cascade, traceable to a shared macro.

---

## 2. Large code generation

**Problem**

A macro that expands into a large amount of code affects both the compiler
and the runtime: Elixir may need to expand, compile, and execute that
generated code many times (once per call site), which slows compilation and
bloats the resulting build artifacts.

**Anti-pattern**

```elixir
defmodule Routes do
  defmacro get(route, handler) do
    quote do
      route = unquote(route)
      handler = unquote(handler)

      if not is_binary(route) do
        raise ArgumentError, "route must be a binary"
      end

      if not is_atom(handler) do
        raise ArgumentError, "handler must be a module"
      end

      @store_route_for_compilation {route, handler}
    end
  end
end
```

**Refactored**

```elixir
defmodule Routes do
  defmacro get(route, handler) do
    quote do
      Routes.__define__(__MODULE__, unquote(route), unquote(handler))
    end
  end

  def __define__(module, route, handler) do
    if not is_binary(route) do
      raise ArgumentError, "route must be a binary"
    end

    if not is_atom(handler) do
      raise ArgumentError, "handler must be a module"
    end

    Module.put_attribute(module, :store_route_for_compilation, {route, handler})
  end
end
```

Move validation and any non-trivial logic out of the `quote` block and into
a plain helper function (called from a *small* generated snippet). Every
call site then expands to a tiny call instead of duplicating the full logic
inline.

**Detection heuristics**

- A `quote do ... end` block contains conditionals, raises, loops, or
  multi-step logic rather than a thin call into a regular function.
- Compilation time or `_build` artifact size grows noticeably with the
  number of call sites of a given macro.

---

## 3. Unnecessary macros

**Problem**

Macros are a powerful meta-programming mechanism, but they should be used
only when a function (or another existing Elixir construct) genuinely can't
solve the problem. Reaching for a macro when a plain function would do makes
the code more complex and less readable than necessary, and forces callers
to `require` the module.

**Anti-pattern**

```elixir
defmodule MyMath do
  defmacro sum(v1, v2) do
    quote do
      unquote(v1) + unquote(v2)
    end
  end
end
```

```elixir
iex> require MyMath
MyMath
iex> MyMath.sum(3, 5)
8
iex> MyMath.sum(3 + 1, 5 + 6)
15
```

**Refactored**

```elixir
defmodule MyMath do
  def sum(v1, v2) do
    v1 + v2
  end
end
```

```elixir
iex> MyMath.sum(3, 5)
8
iex> MyMath.sum(3+1, 5+6)
15
```

Prefer a regular named function; it does the same job here, needs no
`require/2` at call sites, and is simpler to read and maintain.

**Detection heuristics**

- A `defmacro` body never uses `quote`'s ability to inject code into the
  caller's context in a way a function couldn't already achieve (no control
  over evaluation, no AST manipulation, no injecting definitions).
- A macro's `quote` block is equivalent to a straight-line function body
  with `unquote` standing in for ordinary function arguments.

---

## 4. `use` instead of `import`

**Problem**

`use/1` has a much broader scope than `import/1`: a `__using__/1` callback
can inject arbitrary code into the calling module, including further
`import`s, other macros, module attributes, or `@behaviour`s — none of which
is visible at the call site. This makes code harder to read, since
understanding what `use SomeModule` actually does requires reading
`SomeModule`'s internals, not just its public docs.

**Anti-pattern**

```elixir
defmodule ModuleA do
  def foo do
    "From Module A"
  end
end

defmodule Library do
  defmacro __using__(_opts) do
    quote do
      import Library
      import ModuleA
    end
  end

  def from_lib do
    "From Library"
  end
end

defmodule ClientApp do
  use Library

  def foo do
    "Local function from client app"
  end

  def from_client_app do
    from_lib() <> " - " <> foo()
  end
end
```

**Refactored**

```elixir
defmodule ClientApp do
  import Library

  def foo do
    "Local function from client app"
  end

  def from_client_app do
    from_lib() <> " - " <> foo()
  end
end
```

```elixir
iex> ClientApp.from_client_app()
"From Library - Local function from client app"
```

If all `__using__/1` does is `import` some modules, replace `use Library`
with a plain `import Library` (and `import ModuleA` if that's also needed)
at the call site — `import/1` doesn't hide anything, its effect is entirely
visible in the file that uses it.

**Additional remarks**

Library authors should avoid `__using__/1` callbacks whenever `alias/1` or
`import/1` would be sufficient. When `use MyModule` genuinely is necessary
(e.g. to inject a `@behaviour`, register attributes, or define callback
functions), document exactly what it injects into the caller — similar in
spirit to a "Nutrition facts" label — so users don't have to read the macro
implementation to know what they're opting into.

**Detection heuristics**

- A `__using__/1` callback's `quote` block contains only `import`/`alias`
  calls and nothing that genuinely requires macro injection
  (`@behaviour`, attribute registration, `@before_compile`, generated
  callbacks).
- A library's `use MyLib` has no accompanying documentation of what code it
  injects into the caller.

---

## 5. Untracked compile-time dependencies

**Problem**

The mirror image of "Compile-time dependencies": this happens when a real
compile-time dependency exists, but it's constructed in a way the Elixir
compiler can't see, so it isn't recorded — meaning the compiler won't
recompile dependents when it should. This typically happens when building
module aliases *dynamically*, whether inside a module body or a macro.

**Anti-pattern**

```elixir
defmodule MyModule do
  parts = [:Foo, :Bar]

  for part <- parts do
    Module.concat(OtherModule, part).example()
  end
end
```

```elixir
defmodule MyModule do
  mods = [:"Elixir.OtherModule.Foo", :"Elixir.OtherModule.Bar"]

  for mod <- mods do
    mod.example()
  end
end
```

**Refactored — use full module names directly**

```elixir
defmodule MyModule do
  mods = [OtherModule.Foo, OtherModule.Bar]

  for mod <- mods do
    mod.example()
  end
end
```

**Refactored — build the alias inside a macro so it's unquoted, not computed at runtime**

```elixir
defmodule MyMacro do
  defmacro call_examples(parts) do
    for part <- parts do
      quote do
        OtherModule.unquote(part).example()
      end
    end
  end
end

defmodule MyModule do
  import MyMacro
  call_examples [:Foo, :Bar]
end
```

Avoid programmatically building a module name at runtime via
`Module.concat/2` or dynamic atom/string construction when the compiler
needs to track the dependency. Either reference the full module name
literally so the compiler can see it, or, if the set of modules must be
generated, do the generation inside a macro using `unquote/1` so the
reference is visible to the compiler at expansion time.

**Detection heuristics**

- `Module.concat/1,2` or a dynamically built atom/string (e.g.
  `String.to_existing_atom("Elixir." <> name)`) is used to call functions on
  a module that is otherwise a normal, static compile-time dependency of the
  project.
- Changing a module doesn't trigger recompilation of a dependent file that
  clearly calls into it (only reachable through a dynamically constructed
  alias).
