# Supported Locales

NeoFaker supports locale-specific data for realistic test output. Almost every function that
accepts a `:locale` option is locale-aware, and loads its data from
`priv/data/<locale>/<domain>/<file>.exs` inside the package. If the requested locale has no data
file for that particular domain/file combination, NeoFaker falls back to `priv/data/default/`
(generic English (US) data) for that lookup only, rather than raising.

## Available Locales

| Locale     | Country      | Language                           |
| ---------- | ------------ | ----------------------------------- |
| `:default` | 🌐 N/A       | English (US), not country-specific |
| `:id_id`   | 🇮🇩 Indonesia | Bahasa Indonesia                   |

`:default` is not itself a locale code, since it's the baseline dataset every other locale falls
back to. `:en_us` is accepted as a locale value but currently has no dataset of its own; it resolves
to `:default` data. `:id_id` has its own data for several domains (`Address`, `App`, `Color`,
`Person`), and falls back to `:default` for the rest.

## Setting the locale

There are three ways to control which locale a function draws from, checked in this order:

1. **Per call.** Pass `locale: :id_id` (or any supported locale) directly to the function.
   This overrides everything else for that one call only.
2. **Per process.** Call `NeoFaker.Locale.set/1` once, and every subsequent call in that
   process uses it until changed. This is process-scoped (stored in the process dictionary), so
   it's safe to use inside `async: true` tests without affecting other tests running
   concurrently.
3. **Application-wide.** Set `config :neo_faker, locale: ...` in your config files. This is the
   fallback used by any process that hasn't called `NeoFaker.Locale.set/1`, and the right choice
   for a whole application's default (e.g. a Phoenix app's `config/dev.exs`).

```elixir
# Per call, overrides everything else for this one call
iex> NeoFaker.App.description(locale: :id_id)
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."

# Per process, affects every call in the current process from here on
iex> NeoFaker.Locale.set(:id_id)
:ok
iex> NeoFaker.App.description()
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."
```

If an unsupported locale is passed to either `NeoFaker.Locale.set/1` or a function's `:locale`
option, NeoFaker raises `ArgumentError` listing the currently supported locales, the same list
shown in the table above and returned by `NeoFaker.Locale.supported/0`.

See the [configuration instructions](https://hexdocs.pm/neo_faker/getting-started.html#configuration)
for how to set the application-wide default, including notes for Phoenix projects.

## Locale-exclusive generators

Some data only makes sense for a single locale and isn't expressed as a `:locale` option on a
shared function. For example, a US Social Security Number has no Indonesian equivalent to fall
back to. These live under their own `NeoFaker.Locales.*` namespace instead:

```elixir
iex> NeoFaker.Locales.EnUs.Person.ssn()
"184-63-2006"

iex> NeoFaker.Locales.IdId.Person.nik()
"7645504903500640"
```

See the [Locale Cheat Sheet](locale-cheat.html) for a quick reference grouped by locale, or the
"Locale Random Generators" group in the [API Reference](https://hexdocs.pm/neo_faker/api-reference.html)
for the full module docs.

## Adding a new locale

A new locale needs a directory under `priv/data/<locale>/` mirroring the domains it covers (only
the files you provide are used, and anything missing falls back to `:default`, so a partial
locale is valid), and its code added to the `@supported_locales` list in `NeoFaker.Locale` (kept
alphabetically sorted). Locale-exclusive generators, if any, go under
`lib/neo_faker/locales/<locale>/`.

See [Adding a Locale](adding-a-locale.html) for the full contributor walkthrough, from picking a
locale code through opening the pull request. Open an issue or pull request on
[GitHub](https://github.com/muzhawir/neo_faker) to propose one.
