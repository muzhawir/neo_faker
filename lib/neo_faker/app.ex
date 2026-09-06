defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating app metadata.

  Provides utilities to generate random app-related information, including author names, app
  names, descriptions, versions, licenses, bundle identifiers, and package names with support for
  multiple locales and formatting options.
  """
  @moduledoc since: "0.4.0"

  alias NeoFaker.App.DomainGenerator
  alias NeoFaker.App.NameGenerator
  alias NeoFaker.App.SemverGenerator
  alias NeoFaker.App.Validator
  alias NeoFaker.Data
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

  Delegates to `NeoFaker.Person.full_name/1`, with `:middle_name` defaulting to `false`
  for cleaner attribution strings. Accepts the same options as `full_name/1`.

  ## Options

    * `:middle_name` (boolean) - whether to include a middle name. Defaults to `false`.
    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the generated name. Defaults
      to `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

      iex> NeoFaker.App.author(middle_name: true)
      "Joshua Peter Bennet"

      iex> NeoFaker.App.author(sex: :female)
      "Juliana Silva"

  """
  @spec author(keyword()) :: String.t()
  def author(opts \\ []) do
    opts_with_defaults = Keyword.put_new(opts, :middle_name, false)
    Person.full_name(opts_with_defaults)
  end

  @doc """
  Generates a random short app description.

  Returns a one-line description string selected from locale-specific data.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> NeoFaker.App.description(locale: :id_id)
      "Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."

  """
  @spec description(keyword()) :: String.t()
  def description(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @description_file, "descriptions", opts)
  end

  @doc """
  Generates a random open-source license name.

  Returns a name from a curated list sourced from
  [ChooseALicense](https://choosealicense.com/appendix), such as `"MIT License"`,
  `"Apache License 2.0"`, or `"GNU General Public License v3.0"`.

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: Data.random_value(__MODULE__, @license_file, "licenses")

  @doc """
  Generates a random app name.

  Combines a random first word and last word from locale-specific data, then formats the
  result according to the requested style.

  ## Options

    * `:style` (`nil`, `:camel_case`, `:pascal_case`, `:dashed`, `:underscore`, or `:single`) -
      the case style for the name. `nil` produces a title-spaced format (e.g. `"Neo Faker"`);
      `:single` returns the first word only (e.g. `"Faker"`). Defaults to `nil`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

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
    opts = NimbleOptions.validate!(opts, @name_schema)

    first_name =
      Data.random_value(
        __MODULE__,
        @name_file,
        "first_names",
        locale: Keyword.fetch!(opts, :locale)
      )

    last_name =
      Data.random_value(
        __MODULE__,
        @name_file,
        "last_names",
        locale: Keyword.fetch!(opts, :locale)
      )

    NameGenerator.format_text({first_name, last_name}, Keyword.fetch!(opts, :style))
  end

  @doc """
  Generates a random semantic version number.

  Returns a version string following the [Semantic Versioning](https://semver.org)
  (`MAJOR.MINOR.PATCH`) standard.

  ## Options

    * `:type` (`nil`, `:pre_release`, `:build`, or `:pre_release_build`) - which metadata to
      append. `nil` returns the core version only (e.g. `"1.2.3"`); `:pre_release` appends a
      pre-release label (e.g. `"1.2.3-beta.1"`); `:build` appends build metadata (e.g.
      `"1.2.3+20250325"`); `:pre_release_build` appends both (e.g. `"1.2.3-rc.1+20250325"`).
      Defaults to `nil`.

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
    opts = NimbleOptions.validate!(opts, @semver_schema)

    core = SemverGenerator.semver_core()

    case Keyword.fetch!(opts, :type) do
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
  def version, do: semver() |> String.split(".") |> Stream.take(2) |> Enum.join(".")

  @doc """
  Generates a random app bundle identifier.

  Returns a bundle ID in reverse-domain notation, commonly used for iOS and Android apps.
  The app name portion is generated via `name/1`.

  ## Options

    * `:domain` (string) - the base domain. Defaults to `"example.com"`.
    * `:style` (`:underscore` or `:dashed`) - the name style for the app segment. Defaults to
      `:underscore`.

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
    opts = NimbleOptions.validate!(opts, @bundle_id_schema)

    app_name = name(style: Keyword.fetch!(opts, :style))

    "#{DomainGenerator.reverse_domain!(Keyword.fetch!(opts, :domain))}.#{String.downcase(app_name)}"
  end

  @doc """
  Generates a random app package name.

  Returns a package name in Java reverse-domain notation (e.g. for Android apps).
  The app name segment is lowercased and stripped of all non-alphanumeric characters.

  ## Options

    * `:domain` (string) - the base domain. Defaults to `"example.com"`.

  ## Examples

      iex> NeoFaker.App.package_name()
      "com.example.neofaker"

      iex> NeoFaker.App.package_name(domain: "mycompany.id")
      "id.mycompany.neofaker"

  """
  @spec package_name(keyword()) :: String.t()
  def package_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @package_name_schema)

    app_name = name() |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")

    "#{DomainGenerator.reverse_domain!(Keyword.fetch!(opts, :domain))}.#{app_name}"
  end
end
