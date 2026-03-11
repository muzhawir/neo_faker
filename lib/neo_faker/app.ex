defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating app metadata.

  Provides utilities to generate random app-related information, including author
  names, app names, descriptions, versions, licenses, bundle identifiers, and
  package names with support for multiple locales and formatting options.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Name
  import NeoFaker.App.Semver
  import NeoFaker.Data, only: [random_value: 3, random_value: 4]

  alias NeoFaker.App.Domain
  alias NeoFaker.App.Validator
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Person

  @description_file "description.exs"
  @license_file "license.exs"
  @name_file "name.exs"

  @doc """
  Generates a random app author name.

  Delegates to `NeoFaker.Person.full_name/1` with `:middle_name` defaulting to
  `false` for cleaner attribution strings.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:middle_name` - Include a middle name. Defaults to `false`.
    - `:sex` - Sex of the generated name. One of `:unisex` (default), `:female`, `:male`.
    - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

      iex> NeoFaker.App.author(middle_name: true)
      "José Carlos Valim"

      iex> NeoFaker.App.author(sex: :female)
      "Juliana Silva"

  """
  @spec author(Keyword.t()) :: String.t()
  def author(opts \\ []) do
    # Set default middle_name to false for cleaner author names
    opts_with_defaults = Keyword.put_new(opts, :middle_name, false)
    Person.full_name(opts_with_defaults)
  end

  @doc """
  Generates a random short app description.

  Returns a one-line description string selected from locale-specific data.
  Pass `locale:` to override the application's configured locale.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> NeoFaker.App.description(locale: :id_id)
      "Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."

  """
  @spec description(Keyword.t()) :: String.t()
  def description(opts \\ []) do
    random_value(__MODULE__, @description_file, "descriptions", opts)
  end

  @doc """
  Generates a random open-source license name.

  Returns a name from a curated list sourced from
  [ChooseALicense](https://choosealicense.com/appendix), such as
  `"MIT License"`, `"Apache License 2.0"`, or `"GNU General Public License v3.0"`.

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: random_value(__MODULE__, @license_file, "licenses")

  @doc """
  Generates a random app name.

  Combines a random first word and last word from locale-specific data, then
  formats the result according to the requested style.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:style` - Case style for the name. Defaults to `nil` (title-spaced).
    - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Options

  The values for `:style` can be:

  - `nil` - Title-spaced format, e.g. `"Neo Faker"` (default).
  - `:camel_case` - e.g. `"neoFaker"`.
  - `:pascal_case` - e.g. `"NeoFaker"`.
  - `:dashed` - e.g. `"neo-faker"`.
  - `:underscore` - e.g. `"neo_faker"`.
  - `:single` - First word only, e.g. `"Faker"`.

  ## Examples

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

      iex> NeoFaker.App.name(style: :dashed)
      "neo-faker"

      iex> NeoFaker.App.name(locale: :id_id)
      "Garuda Web"

  """
  @spec name(Keyword.t()) :: String.t()
  def name(opts \\ []) do
    style = Options.get(opts, :style, nil)
    locale = Options.get(opts, :locale, :default)

    Validator.validate_name_style!(style)

    first_name = random_value(__MODULE__, @name_file, "first_names", locale: locale)
    last_name = random_value(__MODULE__, @name_file, "last_names", locale: locale)

    format_text({first_name, last_name}, style)
  end

  @doc """
  Generates a random semantic version number.

  Returns a version string following the [Semantic Versioning](https://semver.org)
  (`MAJOR.MINOR.PATCH`) standard. Use `:type` to append pre-release or build metadata.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Version format variant. Defaults to `nil` (core only).

  ## Options

  The values for `:type` can be:

  - `nil` - Core `MAJOR.MINOR.PATCH` format, e.g. `"1.2.3"` (default).
  - `:pre_release` - Appends a pre-release label, e.g. `"1.2.3-beta.1"`.
  - `:build` - Appends build metadata, e.g. `"1.2.3+20250325"`.
  - `:pre_release_build` - Appends both, e.g. `"1.2.3-rc.1+20250325"`.

  ## Examples

      iex> NeoFaker.App.semver()
      "1.2.3"

      iex> NeoFaker.App.semver(type: :pre_release)
      "1.2.3-beta.1"

      iex> NeoFaker.App.semver(type: :build)
      "1.2.3+20250325"

      iex> NeoFaker.App.semver(type: :pre_release_build)
      "1.2.3-rc.1+20250325"

  """
  @spec semver(Keyword.t()) :: String.t()
  def semver(opts \\ []) do
    type = Options.get(opts, :type, nil)
    Validator.validate_semver_type!(type)

    core = semver_core()

    case type do
      nil -> core
      :pre_release -> "#{core}-#{semver_pre_release()}"
      :build -> "#{core}+#{semver_build_number()}"
      :pre_release_build -> "#{core}-#{semver_pre_release()}+#{semver_build_number()}"
    end
  end

  @doc """
  Generates a simplified `MAJOR.MINOR` version number.

  Derives the version by taking the first two components of a `semver/1` result.

  ## Examples

      iex> NeoFaker.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version, do: semver() |> String.split(".") |> Enum.take(2) |> Enum.join(".")

  @doc """
  Generates a random app bundle identifier.

  Returns a bundle ID in reverse-domain notation, commonly used for iOS and
  Android apps. The app name portion is generated via `name/1` and formatted
  with the given `:style`. Only `:underscore` and `:dashed` styles are supported.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:domain` - Base domain. Defaults to `"example.com"`.
    - `:style` - Name style for the app segment. Either `:underscore` (default) or `:dashed`.

  ## Examples

      iex> NeoFaker.App.bundle_id()
      "com.example.neo_faker"

      iex> NeoFaker.App.bundle_id(style: :dashed)
      "com.example.neo-faker"

      iex> NeoFaker.App.bundle_id(domain: "mycompany.io")
      "io.mycompany.neo_faker"

  """
  @spec bundle_id(Keyword.t()) :: String.t()
  def bundle_id(opts \\ []) do
    domain = Options.get(opts, :domain, "example.com")
    style = Options.get(opts, :style, :underscore)

    Validator.validate_domain!(domain)
    Validator.validate_name_style_for_bundle!(style)

    app_name = name(style: style)
    "#{Domain.reverse_domain!(domain)}.#{String.downcase(app_name)}"
  end

  @doc """
  Generates a random app package name.

  Returns a package name in Java reverse-domain notation (e.g. for Android apps).
  The app name segment is lowercased and stripped of all non-alphanumeric characters.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:domain` - Base domain. Defaults to `"example.com"`.

  ## Examples

      iex> NeoFaker.App.package_name()
      "com.example.neofaker"

      iex> NeoFaker.App.package_name(domain: "mycompany.id")
      "id.mycompany.neofaker"

  """
  @spec package_name(Keyword.t()) :: String.t()
  def package_name(opts \\ []) do
    domain = Options.get(opts, :domain, "example.com")

    Validator.validate_domain!(domain)

    # Package names use lowercase, no special characters
    app_name = name() |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")

    "#{Domain.reverse_domain!(domain)}.#{app_name}"
  end
end
