# Changelog

## v0.16.0 (2026-09-29)

A correctness release. It fixes bugs found in a full audit of the library, several of which
changed generated output silently, and tightens validation that used to let invalid input
through. The public API is unchanged except where noted under Breaking Changes.

### Breaking Changes

- **An unsupported `:locale` option now raises `NimbleOptions.ValidationError`.** It used to fall
  back to `:default` silently, so a typo such as `locale: :id` returned English data. The
  per-file fallback for locales that do not ship a data file is unchanged.
- **`NeoFaker.start/0` no longer prints to standard output**, and no longer sets a process
  locale. It still starts the application and now raises `ArgumentError` for an invalid
  `config :neo_faker, locale: ...`.
- **`NeoFaker.App.name(style: :dashed)`** returns lowercase kebab-case (`"neo-faker"`), as its
  documentation always stated, instead of `"Neo-Faker"`.
- **`NeoFaker.Time.add/2`** offsets from the current UTC time, matching `NeoFaker.Time.now/0`,
  instead of the host's local time.
- **Range arguments are checked for emptiness instead of order.** Descending ranges with a
  negative step, such as `10..1//-1`, are now accepted; empty ranges, such as `1..10//-1`, raise
  `ArgumentError` before `Enum.random/1` can raise `Enum.EmptyError`.
- **Invalid positional arguments raise `ArgumentError` consistently.** `NeoFaker.Internet.slug/2`
  and `NeoFaker.Lorem.paragraphs/2`, `sentences/2`, and `words/2` used to raise
  `FunctionClauseError` for a non-positive count. `NeoFaker.Number.between/2`,
  `positive/1`, `negative/1`, and `decimal/3` now raise `ArgumentError` for non-numeric input.
- **An empty `:domain_name`** in `NeoFaker.Internet` raises `NimbleOptions.ValidationError`
  instead of `ArgumentError`, like every other invalid option.
- **`NeoFaker.seed/1` uses the `:exsss` algorithm**, the `:rand` default, so seeded sequences
  differ from v0.15.0.
- **Error messages were reworded** to follow the Elixir convention of starting in lowercase.
  Match on the exception type rather than the message text.
- **Locale data:** `person/name_affixes.exs` gains `"female_prefixes"` and `"male_prefixes"`
  keys, which a locale that ships this file must define.

### Bug Fixes

- `NeoFaker.Internet.ipv4/1` never generated addresses in `170.0.0.0/8` or `171.0.0.0/8`, two
  fully public blocks missing from its first-octet table.
- `NeoFaker.Color.random/1` raised for any `:format` other than `:w3c`, including an explicit
  `format: nil`, and built a color in all six models to return one.
- `NeoFaker.Color.keyword/1` with `category: :all` returned the 15 basic colors twice as often as
  the others, because they are also listed as extended colors. Pooled draws across several
  categories (emoji, TLDs, popular domains, user agents, status codes) now count each value once.
- `NeoFaker.Gravatar.display/2` accepted any string that merely contained an email address, and
  put a custom `:fallback` URL into the query string without encoding it, so a URL with its own
  query string produced a broken avatar URL.
- `NeoFaker.Time.between/2` could return a time after `finish` when a bound had sub-second
  precision.
- `NeoFaker.Person.full_name_with_title/1` could pair a name with a title of the other sex, such
  as `"Mr. Jane Doe"`. `NeoFaker.Person.prefix/1` takes a new `:sex` option.
- `NeoFaker.Number.float/2` crashed with a negative `right_digit`; `decimal/3` and the
  `:precision` option of `NeoFaker.Address` raised an unhelpful error above 15 decimal places;
  float draws between bounds near the largest float raised `ArithmeticError`.
- `NeoFaker.Boolean.boolean(0)` could return `true`, because `:rand.uniform/0` can return `0.0`.
- `NeoFaker.Locales.EnUs.Person.ssn/0` generated area number `777` twice as often as any other.
- `NeoFaker.Locales.IdId.Person.nik/0` and `npwp/0` built the six-digit region code from
  arbitrary ranges, so most codes named no real place (province `20`, for example). The code is
  now drawn from the 7,285 official district (kecamatan) codes of Kepmendagri
  No. 300.2.2-2430 Tahun 2025, covering all 38 provinces.
- `NeoFaker.Crypto` hashes and UUIDs ignored `NeoFaker.seed/1`. `token/2` still uses
  cryptographically strong bytes and is documented as the one generator that cannot be seeded.
- An empty `:number_range` in `NeoFaker.Internet.username/1` and `email/1` raises a validation
  error instead of `Enum.EmptyError`.
- Usernames and slugs keep the base letter of accented characters (`"José"` becomes `"jose"`,
  not `"jos"`).
- The `:locale` segment of a data file path is validated before use, so a crafted locale atom
  can no longer point the data loader outside `priv/data/`.
- `mix.exs` no longer lists `:mix` as a runtime application of the library.

### Improvements

- `NeoFaker.Lorem` parses its source text once per locale instead of on every call, making word
  and sentence generation about 40 times faster.
- A locale that falls back to `:default` for a file no longer checks the file system on every
  call.
- Data cleanup: duplicate entries, two emoji with a leading space, typos in the Lorem ipsum
  text, TLDs filed under the wrong category, and prefix titles listed as Indonesian suffixes.
- Documentation rewritten throughout in the style of the Elixir standard library, with corrected
  examples. The cheatsheet is now generated from the function docs by
  `scripts/gen_cheatsheet.exs`, so the two cannot drift apart. `mix docs` builds without
  warnings.

## v0.15.0 (2026-09-06)

A large internal rewrite. Some thin top-level functions were removed outright rather than deprecated (a formal
deprecation cycle starts in v0.20.0), but each has a one-to-one replacement. Options that changed a function's
return type were removed. Everything else is internal: how locale state is scoped, how options are validated, and
where the private modules live.

### Features

- `NeoFaker.seed/1` seeds `:rand` for the calling process, for reproducible output in tests.
- `NeoFaker.Person.gender/1` takes a `:format` option (`:binary`, `:short_binary`, `:non_binary`, or `:all`, which
  pools the binary and non-binary identities). Replaces `binary_gender/1`, `short_binary_gender/1`,
  `non_binary_gender/1`.
- `NeoFaker.Address.latitude/1` and `longitude/1` return a single coordinate component.
- `NeoFaker.HTTP.user_agent/1` takes `type: :ai`, drawing from a new list of AI crawler and agent
  bot tokens (`"gptbot"`, `"claude-user"`, `"perplexitybot"`, and so on); `:all` includes them.
  Crawler user-agents are now bare bot tokens rather than full UA strings.
- `NeoFaker.HTTP.request_method/1` and `all_request_methods/0` now include the `QUERY` method.
  It counts as common, so the default (`common_only: true`) pool is six methods, not five.
- `NeoFaker.Locale` owns all locale state (`fetch/0`, `get/0`, `set/1`) and the supported-locale list
  (`supported/0`, `available?/1`), previously split between `NeoFaker` and the hidden `NeoFaker.Data`.
- `NeoFaker.Gravatar.random_display/0` replaces `random/0`.

### Breaking Changes

- **Invalid options raise `NimbleOptions.ValidationError`, not `ArgumentError`.** The internal `Helpers.Options`
  wrapper is gone; `NimbleOptions.validate!/2` is called directly. Positional-argument and unsupported-locale errors
  still raise `ArgumentError`.
- **`:format` is removed from `NeoFaker.Date` and `NeoFaker.Time`.** They always return a `Date` / `Time` struct;
  call `Date.to_iso8601/1` / `Time.to_iso8601/1` for a string. Signatures lose an argument, e.g.
  `NeoFaker.Date.add/1`, `NeoFaker.Date.between/2`, `NeoFaker.Time.between/2`; the period helpers
  (`NeoFaker.Time.morning/0` through `night/0`) and `NeoFaker.Time.now/0` take no arguments, while
  `NeoFaker.Time.add/2` keeps `:unit`. `NeoFaker.Date.past/1` and `NeoFaker.Date.future/1` now raise
  `ArgumentError` for a non-positive day count.
- **`:join` is removed from `NeoFaker.Lorem` `paragraphs`/`sentences`/`words` and `NeoFaker.Text.words`.** They
  always return a list; join it with `Enum.join/2`. `NeoFaker.Text.words/1` no longer takes options.
- **`:type` is removed from `NeoFaker.Address.coordinate/1`** (always a `{lat, lng}` tuple) **and
  `building_number/1`** (always a string; the second argument is gone too).
- **`:integer` is removed from `NeoFaker.Boolean.boolean/1`** (always a boolean; the second argument is gone too).
- **`NeoFaker.Locale.set/1` is process-scoped, not node-global.** It writes to the process dictionary, not
  `Application.put_env/3`, so it never leaks between processes. Use `config :neo_faker, locale: ...` for a node-wide
  default.
- **Locale-exclusive modules moved:** `NeoFaker.EnUs.*` / `NeoFaker.IdId.*` are now `NeoFaker.Locales.EnUs.*` /
  `NeoFaker.Locales.IdId.*`.
- **Removed, each with a drop-in replacement:** `NeoFaker.locale/0`, `set_locale/1`, `get_locale/0` (use
  `NeoFaker.Locale.fetch/0`, `set/1`, `get/0`); `Person.binary_gender/1`, `short_binary_gender/1`,
  `non_binary_gender/1` (use `gender/1`); `Gravatar.random/0` (use `random_display/0`);
  `Data.supported_locales/0`, `locale_available?/1` (use `NeoFaker.Locale.supported/0`, `available?/1`).
- **`NeoFaker.Internet.email/1`** reads only the prefixed option names now (`:username_word_count`,
  `:domain_name_word_count`, `:tld_type`), not the bare `:word_count` / `:type` fallbacks.
- **`nimble_options ~> 1.1`** is now a runtime dependency.

### Bug Fixes

- `Person.first_name/1`, `middle_name/1`, `last_name/1`, `full_name/1`, `App.name/1`, and `Color.keyword/1` now
  honour the configured locale when no `:locale` option is passed; they hardcoded `:default` before.
- `NeoFaker.Data` no longer reseeds `:rand` on the first read of a data file, which silently overrode a caller's
  seed.
- `Internet.username/1`, `domain_name/1` (`type: :random`), and `slug/2` now emit only lowercase alphanumeric
  segments; a word carrying a space, hyphen, apostrophe, or accent used to leak through. Phrase entries were dropped
  from the word list.
- `Lorem.word/1` and `sentence/1` no longer raise `Enum.EmptyError` when the source text splits around a blank
  fragment.

### Improvements

- Ran the full Elixir anti-pattern catalogue over `lib/` and closed every finding. Beyond the return-type changes
  above: `Map.fetch!/2` instead of `Map.get/2` for schema-guaranteed keys, `App.package_name/1` reuses
  `Formatter.slugify/1`, `Person.age/2` drops validation it duplicated, and two test-only `Internet.Generator`
  functions are marked `@doc false`.
- Private submodules (all `@moduledoc false`) now follow one naming convention: `<Domain>.Generator` and
  `<Domain>.Validator`. Every bare `import` of a project module was replaced with an `alias`.
- Locale and data backend simplified (internal only): `priv/data/locale.exs` is replaced by a module attribute in
  `NeoFaker.Locale`, and `NeoFaker.Data` collapsed to one `load/3` path shared by `random_value/4` and `fetch!/3`,
  which now share the per-file `:default` fallback.
- `NeoFaker.Internet.Generator` refactored for readability (named octet helpers, pattern-matched `reserved_ipv4?/3`,
  a pure `compress_ipv6_groups/1`); output is unchanged.
- Documentation pages sorted into `guides/`, `reference/`, `contributing/`, and `about/` subfolders, one per ExDoc
  sidebar group. URLs are unchanged.
- Test suite overhauled across every domain; total line coverage is now 100%.

## v0.14.0 (2026-03-11)

### Features

- Added `NeoFaker.Data.supported_locales/0`, which returns the supported locale atoms from
  `priv/data/locale.exs`, cached in `:persistent_term`.
- Added `NeoFaker.Gravatar.profile/2`, which generates a Gravatar profile URL with `:format`
  option (`:html`, `:json`, `:xml`, `:php`, `:vcf`, `:qr`).
- Added `NeoFaker.Gravatar.random/0`, which generates a Gravatar image URL with a random size and
  fallback type.
- Added `NeoFaker.Gravatar.fallback_types/0`, `default_size/0`, and `size_range/0` as public
  introspection helpers.
- Added `NeoFaker.Gravatar.display/2` options `:rating` (`:g`, `:pg`, `:r`, `:x`) and
  `:force_default` (appends `&f=y` when `true`).
- Added `NeoFaker.App.Validator.validate_domain!/1`, which raises `ArgumentError` on invalid
  domain strings, replacing silent `MatchError` in `bundle_id/1` and `package_name/1`.
- Added `NeoFaker.Internet.Validator.validate_ipv4_class!/1`, which raises `ArgumentError` on
  invalid `:class` values in `ipv4/1`, replacing `FunctionClauseError`.
- Added `NeoFaker.Internet.Generator.reserved_ipv4?/3`, a public predicate for all IANA-reserved
  IPv4 ranges, usable independently of the generator.
- Added `NeoFaker.Helpers.Formatter` for format conversions and `NeoFaker.Helpers.Options` for
  option extraction and validation.
- Added `NeoFaker.IdId.Person.npwp/0` for generating Indonesian tax identification numbers (NPWP).
- Added `NeoFaker.Address.Generator` with `latitude/1` and `longitude/1`.
- Consolidated all data-access helpers into `NeoFaker.Data`.

### Improvements

- **`public_ipv4/0`** now excludes all IANA-reserved ranges: `0.0.0.0/8`, `10.0.0.0/8`,
  `100.64.0.0/10`, `127.0.0.0/8`, `169.254.0.0/16`, `172.16.0.0/12`, `192.0.0.0/24`,
  `192.0.2.0/24`, `192.88.99.0/24`, `192.168.0.0/16`, `198.18.0.0/15`, `198.51.100.0/24`,
  `203.0.113.0/24`, `224.0.0.0/4`, and `240.0.0.0/4`. First-octet selection uses a compile-time
  cumulative weight table for O(1) performance.
- **`url_path/0` and `query_string/0`** now slugify multi-word entries from `Text.word/0` (e.g.
  `"ice cream"`) (spaces become `-`) before use in path segments and query keys.
- **`url/1`** no longer produces double-TLD output (e.g. `"gmail.com.net"`) for `:popular` and
  `:custom` domain types; TLD is now only appended for `:random` domains.
- **`set_locale/1`** now validates the locale against `supported_locales/0` before storing, and
  the error message lists all valid values.
- **`NeoFaker.Data`** now resolves the locale file via `:code.priv_dir/1`, fixing lookup when
  NeoFaker is used as a Mix dependency.
- **`Crypto.token/2`**'s guard no longer matches any integer incorrectly; `ArgumentError` is
  now raised only for non-positive lengths.
- **`Number.decimal/3`** now delegates to `between/2` before rounding, inheriting `min > max`
  validation.
- Extracted `Validator` and `Generator` sub-modules across all major modules: `Address`, `App`,
  `Blood`, `Boolean`, `Color`, `Crypto`, `Date`, `Gravatar`, `HTTP`, `Internet`, `Lorem`,
  `Number`, `Person`, `Text`, and `Time`.
- Removed `NeoFaker.Helpers.Constants` in favour of module attributes.
- Added `@doc` to all sub-module functions for improved autocomplete.
- Bumped minimum Erlang/OTP to 28.0 and Elixir to 1.18.4. Pinned dev toolchain to OTP 28.3 and
  Elixir 1.19.4 in `mise.toml` and CI.
- Renamed the "Available Locales" docs page to "Locales".

### Bug Fixes

- `bundle_id/1` and `package_name/1` now raise `ArgumentError` (not `MatchError`) for domains
  with no dot or empty strings.
- `ipv4/1` now raises `ArgumentError` (not `FunctionClauseError`) for unsupported `:class` values.
- `public_ipv4/0` no longer generates loopback, private, link-local, multicast, CGN, or
  test/documentation addresses.
- Fixed off-by-one in `find_octet_in_table/2` cumulative weight lookup.
- Fixed `Address.city/0` returning `nil` for some locales.
- Fixed `Date.birthday/3` start date calculation.
- Fixed crash in `Time.time_zone/0` when locale data is incomplete.
- Scoped `:persistent_term` cache keys to tuples to prevent cross-module collisions.
- Added path-traversal validation on data file names in `NeoFaker.Data`.
- `domain_name/1` with `type: :custom` now raises `ArgumentError` for a non-string or empty
  `:domain_name`, preventing bad values from propagating into `email/1` and `url/1`.
- `validate_domain!/1` now enforces RFC 1123 label rules, namely alphanumeric start/end, letters,
  digits, and hyphens only, max 63 chars per label. Rejects trailing dots, `/`, `:`, and
  leading/trailing hyphens.
- `locale/0` now raises `ArgumentError` for unsupported atoms stored directly in the application
  env, preventing `get_locale/0` from reporting a different locale than generators actually use.
- `Number.decimal/3` now raises `ArgumentError` for negative precision (was `FunctionClauseError`).
  The `@spec` is widened to `number()` to reflect that integer bounds are accepted.

### Breaking Changes

- **`set_locale/1`** raises `ArgumentError` for any atom not in `priv/data/locale.exs` (or
  `:default`). Use `NeoFaker.Data.supported_locales/0` to list valid values.
- **`ipv4/0`** (public mode) no longer returns IANA-reserved addresses. Use `ipv4(private: true)`
  if you need a private range address.

### Tests

- Added comprehensive `GravatarTest` coverage: size, fallback types, `:rating`, `:force_default`,
  `profile/2` formats, `random/0`, and all introspection helpers.
- Replaced probabilistic IPv4 sampling with deterministic boundary assertions against
  `reserved_ipv4?/3`, covering all IANA blocks at both endpoints and adjacent public addresses.
  Class-specific private IPv4 tests also verify full four-octet structure.
- Added `AppTest` error-path coverage for `bundle_id/1` and `package_name/1` domain validation.
- Added `CryptoTest` coverage for `token/2` length errors and hash format checks.
- Added `NumberTest` coverage for `decimal/3` range errors, bounds, precision, and mixed-type
  float generation in `between/2`.
- Added `NeoFakerTest` coverage for `set_locale/1` and `locale/0` valid and invalid inputs.
- Refactored all test modules to follow ExUnit conventions: `async: true`, module aliases,
  `refute` over `not assert`, `for` over `Enum.each`, separate assertions over compound `assert`.

## v0.13.0 (2025-10-29)

### Features

Added new module `NeoFaker.Internet` to handle internet-related data generation, including:

- `NeoFaker.Internet.tld/1` for generating random top-level domains (TLDs).
- `NeoFaker.Internet.username/1` for generating random usernames.
- `NeoFaker.Internet.domain_name/1` for generating random domain names.
- `NeoFaker.Internet.email/1` for generating random email addresses.
- `NeoFaker.Internet.ipv4/1` for generating random IPv4 addresses.
- `NeoFaker.Internet.ipv6/1` for generating random IPv6 addresses.
- `NeoFaker.Internet.mac_address/1` for generating random MAC addresses.
- `NeoFaker.Internet.url/1` for generating random URLs.
- `NeoFaker.Internet.slug/2` for generating random URL slugs.

### Improvements

- Changed `.tool-versions` to `mise.toml` for better version management, now NeoFaker uses mise
  as the version manager.
- Upgraded mix dependencies.
- Fixed typo in `cheat.cheatmd` file.
- Refactored `NeoFaker.Data.Cache` and `NeoFaker.Data.Disk` for improved file handling and caching
  mechanisms.

### Module Changes

**Breaking Changes**: Renamed `NeoFaker.Http` to `NeoFaker.HTTP` for consistency.

## v0.12.0 (2025-06-10)

### Features

- Added `NeoFaker.Address` for generating random address components: building numbers, cities, countries, and
  coordinates.
- Added `NeoFaker.Time.time_zone/0` for generating random time zones.

### Improvements

- Unified and clarified documentation for all public functions.
- Refactored generator modules: `NeoFaker.Data.Cache`, `NeoFaker.Data.Disk`,
  `NeoFaker.Data.Generator`, and `NeoFaker.Data.Resolver` for improved organization and
  readability.
- Updated `NeoFaker.Data.Cache.put_cache!/3` to use `Stream.uniq/1` for duplicate removal before
  caching.
- Upgraded mix dependencies.

**Breaking:** Renamed `NeoFaker.Internet` to `NeoFaker.HTTP` with expanded features.

#### `NeoFaker.http` (formerly `NeoFaker.Internet`)

- Added `Http.request_method/0` for random HTTP methods.
- Added `Http.referrer_policy/0` for random referrer policies.
- Added `Http.status_code/1` for random HTTP status codes with filtering.
- Enhanced `Http.user_agent/1` to support `:type` filtering (`:browser` or `:crawler`).

### Argument Standardization

**Breaking:** Default arguments now use explicit atoms:

- `NeoFaker.Color.hex/1` defaults to `:six_digit` (was `nil`).
- `NeoFaker.Color.keyword/1` defaults to `:all` (was `nil`).

### Organization & Locale

- Split large utility modules into smaller, focused modules.
- Improved documentation and examples.
- Added Indonesian locale support.
