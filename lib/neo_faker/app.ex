defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating app metadata.

  This module provides utilities to generate random app-related information, including author
  names, app names, descriptions, versions, and licenses with support for multiple locales
  and formatting options.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Name
  import NeoFaker.App.Semver
  import NeoFaker.Data, only: [random_value: 3, random_value: 4]

  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Person

  @description_file "description.exs"
  @license_file "license.exs"
  @name_file "name.exs"

  @valid_name_styles [:camel_case, :pascal_case, :dashed, :underscore, :single]
  @valid_semver_types [:pre_release, :build, :pre_release_build]

  @doc """
  Generates a random app author name.

  Returns a string representing the full name of the app author. By default, excludes
  middle names for cleaner author attribution.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:middle_name` - Include middle name in author name. Defaults to `false`.
    - `:sex` - Specifies the sex of the author name. Defaults to `:unisex`.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

      iex> NeoFaker.App.author(middle_name: true)
      "José Antonio Valim"

      iex> NeoFaker.App.author(sex: :male, locale: :id_id)
      "Jaka"

      iex> NeoFaker.App.author(sex: :female)
      "Jane Doe"

  """
  @spec author(Keyword.t()) :: String.t()
  def author(opts \\ []) do
    # Set default middle_name to false for cleaner author names
    opts_with_defaults = Keyword.put_new(opts, :middle_name, false)
    Person.full_name(opts_with_defaults)
  end

  @doc """
  Generates a short app description.

  Returns a string representing the app description from locale-specific data sources.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> NeoFaker.App.description(locale: :id_id)
      "Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."

      iex> NeoFaker.App.description(locale: :en_us)
      "A powerful testing library for Elixir applications."

  """
  @spec description(Keyword.t()) :: String.t()
  def description(opts \\ []) do
    random_value(__MODULE__, @description_file, "descriptions", opts)
  end

  @doc """
  Generates a random open-source license.

  Returns a random open-source license name selected from a predefined list based on
  [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

      iex> NeoFaker.App.license()
      "Apache License 2.0"

      iex> NeoFaker.App.license()
      "GNU General Public License v3.0"

  """
  @spec license() :: String.t()
  def license, do: random_value(__MODULE__, @license_file, "licenses")

  @doc """
  Generates a random app name.

  Returns a string representing the app name, which is a combination of a first name and a last
  name formatted according to the specified style.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:style` - Defines the case style of the app name. Defaults to standard format.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  The values for `:style` can be:

  - `nil` (default) - Uses the standard format, e.g., `"Neo Faker"`.
  - `:camel_case` - Uses camel case, e.g., `"neoFaker"`.
  - `:pascal_case` - Uses Pascal case, e.g., `"NeoFaker"`.
  - `:dashed` - Uses a dashed format, e.g., `"neo-faker"`.
  - `:underscore` - Uses an underscore format, e.g., `"neo_faker"`.
  - `:single` - Uses a single-word format, e.g., `"Faker"`.

  The values for `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

  ## Examples

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

      iex> NeoFaker.App.name(style: :pascal_case)
      "NeoFaker"

      iex> NeoFaker.App.name(style: :dashed)
      "neo-faker"

      iex> NeoFaker.App.name(style: :underscore)
      "neo_faker"

      iex> NeoFaker.App.name(style: :single)
      "Faker"

      iex> NeoFaker.App.name(locale: :id_id)
      "Garuda Web"

      iex> NeoFaker.App.name(style: :camel_case, locale: :id_id)
      "garudaWeb"

  """
  @spec name(Keyword.t()) :: String.t()
  def name(opts \\ []) do
    style = Options.get(opts, :style, nil)
    locale = Options.get(opts, :locale, Constants.default_locale())

    validate_name_style!(style)

    first_name = random_value(__MODULE__, @name_file, "first_names", locale: locale)
    last_name = random_value(__MODULE__, @name_file, "last_names", locale: locale)

    format_text({first_name, last_name}, style)
  end

  @doc """
  Generates a semantic version number.

  Returns a version number following the Semantic Versioning (SemVer) standard. By default, it
  generates a core version (`MAJOR.MINOR.PATCH`).

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Specifies the type of version format. Defaults to core version.

  ## Options

  The values for `:type` can be:

  - `nil` (default) - Uses core SemVer format (e.g., `"1.2.3"`).
  - `:pre_release` - Includes a pre-release label (e.g., `"1.2.3-beta.1"`).
  - `:build` - Includes a build metadata label (e.g., `"1.2.3+20250325"`).
  - `:pre_release_build` - Includes both pre-release and build metadata (e.g.,
    `"1.2.3-rc.1+20250325"`).

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
    validate_semver_type!(type)

    core = semver_core()

    case type do
      nil -> core
      :pre_release -> "#{core}-#{semver_pre_release()}"
      :build -> "#{core}+#{semver_build_number()}"
      :pre_release_build -> "#{core}-#{semver_pre_release()}+#{semver_build_number()}"
    end
  end

  @doc """
  Generates a simple version number.

  Returns a version number in the format `MAJOR.MINOR`, which is a simplified version
  derived from the semantic version.

  ## Examples

      iex> NeoFaker.App.version()
      "1.2"

      iex> NeoFaker.App.version()
      "0.14"

      iex> NeoFaker.App.version()
      "3.5"

  """
  @spec version() :: String.t()
  def version, do: semver() |> String.split(".") |> Enum.take(2) |> Enum.join(".")

  @doc """
  Generates a random app bundle identifier.

  Returns a bundle identifier commonly used in mobile apps (e.g., iOS, Android).
  The format follows reverse domain name notation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:domain` - Custom domain to use. Defaults to random domain.
    - `:style` - Name style for the app portion. Defaults to `:underscore`.

  ## Examples

      iex> NeoFaker.App.bundle_id()
      "com.example.neo_faker"

      iex> NeoFaker.App.bundle_id(domain: "mycompany.io")
      "io.mycompany.app_name"

      iex> NeoFaker.App.bundle_id(style: :dashed)
      "com.example.neo-faker"

  """
  @spec bundle_id(Keyword.t()) :: String.t()
  def bundle_id(opts \\ []) do
    domain = Options.get(opts, :domain, "example.com")
    style = Options.get(opts, :style, :underscore)

    validate_name_style_for_bundle!(style)

    # Parse domain into reverse notation
    [tld | domain_parts] = domain |> String.split(".") |> Enum.reverse()
    reversed_domain = Enum.join([tld | domain_parts], ".")

    app_name = name(style: style)
    "#{reversed_domain}.#{String.downcase(app_name)}"
  end

  @doc """
  Generates a random app package name.

  Returns a package name in Java package notation, commonly used for Android apps.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:domain` - Custom domain to use. Defaults to random domain.

  ## Examples

      iex> NeoFaker.App.package_name()
      "com.example.neofaker"

      iex> NeoFaker.App.package_name(domain: "mycompany.io")
      "io.mycompany.appname"

  """
  @spec package_name(Keyword.t()) :: String.t()
  def package_name(opts \\ []) do
    domain = Options.get(opts, :domain, "example.com")

    # Parse domain into reverse notation
    [tld | domain_parts] = domain |> String.split(".") |> Enum.reverse()
    reversed_domain = Enum.join([tld | domain_parts], ".")

    # Package names use lowercase, no special characters
    app_name = name() |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")

    "#{reversed_domain}.#{app_name}"
  end

  # Private functions

  @spec validate_name_style!(atom() | nil) :: :ok
  defp validate_name_style!(nil), do: :ok

  defp validate_name_style!(style) do
    valid_styles = [nil | @valid_name_styles]

    case Options.validate_enum(:style, style, valid_styles) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_name_style_for_bundle!(atom()) :: :ok
  defp validate_name_style_for_bundle!(style) when style in [:underscore, :dashed], do: :ok

  defp validate_name_style_for_bundle!(style) do
    raise ArgumentError,
          "Invalid style for bundle_id. Expected one of [:underscore, :dashed], got: #{inspect(style)}"
  end

  @spec validate_semver_type!(atom() | nil) :: :ok
  defp validate_semver_type!(nil), do: :ok

  defp validate_semver_type!(type) do
    valid_types = [nil | @valid_semver_types]

    case Options.validate_enum(:type, type, valid_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
