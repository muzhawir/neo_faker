# Locales

A locale selects the data set a generator draws from, such as Indonesian names instead of US
English ones. Generators that read from a data set accept a `:locale` option; generators whose
output does not depend on language, such as `NeoFaker.Crypto` or `NeoFaker.HTTP`, do not.

## Supported locales

| Locale     | Region        | Language             | Own data for                          |
| ---------- | ------------- | -------------------- | ------------------------------------- |
| `:default` | None          | English (US)         | Every domain                          |
| `:en_us`   | United States | English (US)         | None yet, reads `:default` everywhere |
| `:id_id`   | Indonesia     | Bahasa Indonesia     | `Address`, `App`, `Color`, `Person`   |

`NeoFaker.Locale.supported/0` returns the supported codes. `:default` is not in that list: it
is the baseline data set rather than a regional locale.

### Fallback to `:default`

A locale does not have to ship every data file. When a generator asks for a file the locale
does not have, NeoFaker reads the `:default` copy of that file instead. For example,
`NeoFaker.Text.word(locale: :id_id)` returns an English word, because `:id_id` has no word
list of its own.

This fallback applies to missing data files only. An unsupported locale code is always an
error:

  * `NeoFaker.Locale.set(:fr_fr)` raises `ArgumentError`.
  * `NeoFaker.Person.first_name(locale: :fr_fr)` raises `NimbleOptions.ValidationError`, like
    any other invalid option.

## Choosing the locale

The locale of a generator call is resolved in this order:

  1. **The `:locale` option** of that call.
  2. **The process locale**, set with `NeoFaker.Locale.set/1`. It is stored in the process
     dictionary, so it only affects the calling process and is safe to use in `async: true`
     tests.
  3. **The application locale**, set with `config :neo_faker, locale: ...`. It applies to
     every process that has not set its own.
  4. **`:default`**, when none of the above is set.

```elixir
iex> NeoFaker.Address.city(locale: :id_id)
"Palu"

iex> NeoFaker.Locale.set(:id_id)
:ok

iex> NeoFaker.Address.city()
"Bandung"

iex> NeoFaker.Locale.get()
:id_id
```

The process locale is not inherited by processes spawned afterwards, including `Task`s. Pass
the `:locale` option, or call `NeoFaker.Locale.set/1` inside the new process.

## Locale-exclusive generators

Some formats exist in only one country and have no equivalent to fall back to, such as the US
Social Security Number. These live in their own modules under `NeoFaker.Locales`:

```elixir
iex> NeoFaker.Locales.EnUs.Person.ssn()
"184-63-2006"

iex> NeoFaker.Locales.IdId.Person.nik()
"7645504903500640"
```

They ignore the active locale. See the [Locale Cheatsheet](locale-cheat.html) for the full
list.

## Adding a locale

A new locale needs data files under `priv/data/<locale>/` and its code in the
`@supported_locales` list of `NeoFaker.Locale`. It can start small: every file it leaves out
falls back to `:default`. See [Adding a Locale](adding-a-locale.html) for the full walkthrough.
