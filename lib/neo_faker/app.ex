defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating app metadata.

  Provides utilities to generate random app-related information, including author
  names, app names, descriptions, versions, licenses, bundle identifiers, and
  package names with support for multiple locales and formatting options.
  """
  @moduledoc since: "0.4.0"

  alias NeoFaker.App.DomainGenerator
  alias NeoFaker.App.NameGenerator
  alias NeoFaker.App.SemverGenerator
  alias NeoFaker.App.Validator
  alias NeoFaker.Data
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Person

  @description_file "description.exs"
  @license_file "license.exs"
  @name_file "name.exs"

  @locale_schema NimbleOptions.new!(locale: [type: :atom, default: nil])

  @name_schema NimbleOptions.new!(
                 style: [
                   type: {:in, [nil, :camel_case, :pascal_case, :dashed, :underscore, :single]},
                   default: nil
                 ],
                 locale: [type: :atom, default: nil]
               )

  @semver_schema NimbleOptions.new!(
                   type: [
                     type: {:in, [nil, :pre_release, :build, :pre_release_build]},
                     default: nil
                   ]
                 )

  @bundle_id_schema NimbleOptions.new!(
                      domain: [
                        type: {:custom, Validator, :validate_domain, []},
                        default: "example.com"
                      ],
                      style: [type: {:in, [:underscore, :dashed]}, default: :underscore]
                    )

  @package_name_schema NimbleOptions.new!(
                         domain: [
                           type: {:custom, Validator, :validate_domain, []},
                           default: "example.com"
                         ]
                       )

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
  @spec author(keyword()) :: String.t()
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
  @spec description(keyword()) :: String.t()
  def description(opts \\ []) do
    opts = Options.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @description_file, "descriptions", opts)
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
  def license, do: Data.random_value(__MODULE__, @license_file, "licenses")

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
  @spec name(keyword()) :: String.t()
  def name(opts \\ []) do
    opts = Options.validate!(opts, @name_schema)

    first_name = Data.random_value(__MODULE__, @name_file, "first_names", locale: opts[:locale])
    last_name = Data.random_value(__MODULE__, @name_file, "last_names", locale: opts[:locale])

    NameGenerator.format_text({first_name, last_name}, opts[:style])
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
  @spec semver(keyword()) :: String.t()
  def semver(opts \\ []) do
    opts = Options.validate!(opts, @semver_schema)

    core = SemverGenerator.semver_core()

    case opts[:type] do
      nil ->
        core

      :pre_release ->
        "#{core}-#{SemverGenerator.semver_pre_release()}"

      :build ->
        "#{core}+#{SemverGenerator.semver_build_number()}"

      :pre_release_build ->
        "#{core}-#{SemverGenerator.semver_pre_release()}+#{SemverGenerator.semver_build_number()}"
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
  @spec bundle_id(keyword()) :: String.t()
  def bundle_id(opts \\ []) do
    opts = Options.validate!(opts, @bundle_id_schema)

    app_name = name(style: opts[:style])
    "#{DomainGenerator.reverse_domain!(opts[:domain])}.#{String.downcase(app_name)}"
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
  @spec package_name(keyword()) :: String.t()
  def package_name(opts \\ []) do
    opts = Options.validate!(opts, @package_name_schema)

    # Package names use lowercase, no special characters
    app_name = name() |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")

    "#{DomainGenerator.reverse_domain!(opts[:domain])}.#{app_name}"
  end
end
