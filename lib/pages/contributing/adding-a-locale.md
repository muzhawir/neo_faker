# Adding a Locale

NeoFaker's locale support is entirely data-driven: adding a locale means adding translated data
files and, optionally, a few locale-specific generator functions. No changes to the core
generator logic are needed. This guide walks through the process end to end, using `:id_id`
(the existing Indonesian locale) as the reference example.

See [Locales](locales.html) first if you haven't already, for how locale resolution works from
the caller's side.

## 1. Pick a locale code

A locale code is a lowercase `<language>_<COUNTRY>` pair, joined by an underscore, e.g. `en_us`,
`id_id`. Check `NeoFaker.Locale.supported/0` to make sure the code isn't already taken:

```elixir
iex> NeoFaker.Locale.supported()
[:en_us, :id_id]
```

If you're unsure a locale is worth adding, or want feedback on scope before writing any code,
open an issue on [GitHub](https://github.com/muzhawir/neo_faker) first. A direct pull request
works too.

## 2. Decide what to translate

A locale doesn't need to cover every domain. A partial locale is valid: any file your locale
doesn't provide falls back to `priv/data/default/` (generic English (US) data) automatically, at
the level of an individual file, not the whole locale.

In practice, only domains with culture- or language-specific content are worth localizing.
Compare `priv/data/default/` against the existing `priv/data/id_id/` to see the pattern:

| Domain (`priv/data/default/<domain>/`)                                           | Localized by `id_id`? | Why                                                                                             |
| -------------------------------------------------------------------------------- | --------------------- | ----------------------------------------------------------------------------------------------- |
| `address/` (`city.exs`, `country.exs`)                                           | Yes                   | City and country names are locale-specific.                                                     |
| `app/` (`description.exs`, `name.exs`)                                           | Yes                   | App descriptions and name components read as language text.                                     |
| `color/` (`keyword.exs`)                                                         | Yes                   | Color names are words, so they translate.                                                       |
| `person/` (`female_name.exs`, `male_name.exs`, `gender.exs`, `name_affixes.exs`) | Yes                   | Names, gender terms, and titles are culturally specific.                                        |
| `http/`, `internet/`, `lorem/`, `text/`, `time/`                                 | No                    | User-agents, TLDs, Lorem Ipsum text, emoji, and IANA time zone names aren't tied to a language. |

`app/license.exs` also stays default-only, since license names (`"MIT License"`, etc.) aren't
translated. Treat this table as a starting point, not a hard rule. If your locale has a genuinely
localized alternative for a domain not listed here, that's a reasonable addition too. Just make
the case for it in your PR description.

## 3. Create the data files

Data files live at `priv/data/<locale>/<module_dir>/<file>.exs`, where `<module_dir>` is the
calling module's last name segment, lowercased (e.g. `NeoFaker.Address` reads from `address/`,
`NeoFaker.Person` from `person/`). This mapping is automatic and not configurable, so the
directory name must match exactly.

The easiest way to get the structure right is to copy the matching file from
`priv/data/default/` and translate its values, keeping every map key exactly as-is. The key names
are what each domain module looks up:

| File                      | Keys                                                                               | Notes                                                                                                                                          |
| ------------------------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `address/city.exs`        | `"city"`                                                                           | List of city name strings.                                                                                                                     |
| `address/country.exs`     | `"country"`                                                                        | List of country name strings.                                                                                                                  |
| `app/description.exs`     | `"descriptions"`                                                                   | List of one-line app description strings.                                                                                                      |
| `app/name.exs`            | `"first_names"`, `"last_names"`                                                    | Word banks combined into app names.                                                                                                            |
| `color/keyword.exs`       | `"basic"`, `"extended"`                                                            | Two separate lists. Keep `"basic"` small (the CSS Level 1 palette equivalent); `"extended"` can be larger.                                     |
| `person/female_name.exs`  | `"first_names"`, `"middle_names"`, `"last_names"`                                  | One file per gender, see below.                                                                                                                |
| `person/male_name.exs`    | `"first_names"`, `"middle_names"`, `"last_names"`                                  | Same three keys as the female file.                                                                                                            |
| `person/gender.exs`       | `"binary"`, `"short_binary"`, `"non_binary"`                                       | Keep `"binary"` and `"short_binary"` in the same order as `default` (male first), so the two lists line up.                                    |
| `person/name_affixes.exs` | `"prefixes"`, `"female_prefixes"`, `"male_prefixes"`, `"suffixes"`                 | `"prefixes"` holds titles for anyone, such as `"Dr."`; the other two hold titles for one sex only, such as `"Mrs."` or `"Mr."`. Suffixes go after the name, such as `"Jr."` or `"Ph.D."`. |

Each file is a plain Elixir map literal, evaluated at load time, for example
`priv/data/id_id/address/city.exs`:

```elixir
%{
  "city" => [
    "Jakarta",
    "Surabaya",
    "Medan"
  ]
}
```

A few constraints are enforced by the internal data loader that every domain module goes
through:

- A file you ship replaces the `:default` copy as a whole, so it must define every key listed
  above for that file, even if some lists are short. A missing key raises `KeyError` when a
  generator asks for it.
- The filename must be a bare name ending in `.exs`, with no subdirectories. Match the existing
  filenames in `priv/data/default/` exactly rather than inventing new ones.
- Values are deduplicated once when first loaded, then cached (the per-call pick is a uniform
  random draw, so list order doesn't matter). You don't need to worry about duplicate entries
  yourself, though keeping the list free of obvious duplicates is still good practice for review.
- Aim for a reasonably sized list, dozens of entries rather than two or three, so generated data
  doesn't repeat noticeably in a short test run.

## 4. Register the locale code

Add your locale code to the `@supported_locales` module attribute in `lib/neo_faker/locale.ex`,
keeping the list alphabetically sorted:

```elixir
@supported_locales ~w(en_us id_id your_locale)a
```

This attribute is the single source of truth that `NeoFaker.Locale.supported/0` and
`NeoFaker.Locale.available?/1` read from. Until the code is listed here, passing it to
`NeoFaker.Locale.set/1` or to a `:locale` option raises an error.

## 5. Add locale-exclusive generators (optional)

Some data has no equivalent in other locales at all, for example a national ID number format. For
those, don't add a `:locale` option to an existing shared function. Instead, add a dedicated
module under `lib/neo_faker/locales/<locale>/`, namespaced as `NeoFaker.Locales.<Locale>.<Domain>`
with the locale segment PascalCased (`id_id` becomes `IdId`, `en_us` becomes `EnUs`).

Follow the existing pattern in `lib/neo_faker/locales/id_id/person.ex`:

```elixir
defmodule NeoFaker.Locales.IdId.Person do
  @moduledoc """
  Functions for generating personal details specific to Indonesia.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Locales.IdId.Person.Generator

  @doc """
  Generates a random Nomor Induk Kependudukan (NIK), the Indonesian resident identity
  number.

  ## Examples

      iex> NeoFaker.Locales.IdId.Person.nik()
      "3273014903950042"

  """
  @spec nik() :: String.t()
  def nik do
    # ...
  end
end
```

Put the actual randomization logic in a `Generator` submodule under
`lib/neo_faker/locales/<locale>/<domain>/generator.ex`, marked `@moduledoc false`. This is the
same `Generator` split used by every other domain (see the "Domain modules" section of
`CLAUDE.md`).

Unlike a domain's internal `Generator`/`Validator` submodules, the top-level function here (like
`nik/0`) **is** public API. It needs a full `@doc`/`@spec` and an `## Examples` block, since it
appears in the "Locale Random Generators" group of the API reference. No changes to `mix.exs` are
needed; `groups_for_modules/0` already splits the sidebar by the `NeoFaker.Locales.` prefix.

## 6. Write tests

Data-backed functions (the ones you covered in step 3) don't need new tests just because you
added a locale. The existing test suite exercises every function against whatever locale is
configured. If you want to check your data loads correctly, call the function with your
`locale:` option in an `iex` session (see step 8) instead of adding redundant test cases.

Locale-exclusive generators (step 5) need their own test file at
`test/neo_faker/locales/<locale>/<domain>_test.exs`, mirroring
`test/neo_faker/locales/id_id/person_test.exs`:

```elixir
defmodule NeoFaker.Locales.YourLocale.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Locales.YourLocale.Person

  describe "your_function/0" do
    test "returns a binary string" do
      assert is_binary(Person.your_function())
    end

    test "returns a value of the expected length" do
      assert String.length(Person.your_function()) == 16
    end

    test "returns a value matching the expected format" do
      assert String.match?(Person.your_function(), ~r/^\d{16}$/)
    end
  end
end
```

## 7. Update the docs

- Add a row for your locale to the "Supported locales" table in `lib/pages/guides/locales.md`.
- If you added locale-exclusive generators, add a section title for your locale code to
  `@locale_names` in `scripts/gen_cheatsheet.exs`, then run `mix docs.cheatsheet`. The
  cheatsheets are generated from each function's `## Examples`, so don't edit them by hand.

## 8. Verify

```bash
mix format --check-formatted
mix credo --strict
mix test
mix dialyzer
mix docs
```

Then sanity-check the new locale interactively:

```elixir
iex> NeoFaker.Locale.set(:your_locale)
:ok
iex> NeoFaker.Address.city()
"..."
iex> NeoFaker.Person.full_name()
"..."
```

If a function still returns `:default` data, check that the directory name under
`priv/data/your_locale/` matches the module's downcased last segment exactly, and that the file
name matches the `default` one.

## 9. Open the pull request

Issues and pull requests are welcome on [GitHub](https://github.com/muzhawir/neo_faker). Mention
which domains you localized and which you deliberately left to fall back to `:default`, so
reviewers don't need to guess whether a missing file was intentional.
