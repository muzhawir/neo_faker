defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating app metadata.

  This module provides utilities to generate random app-related information, including author
  names, app names, descriptions, versions, and licenses.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Name
  import NeoFaker.App.Semver
  import NeoFaker.Data.Generator, only: [random_value: 3, random_value: 4]

  alias NeoFaker.Person

  @description_file "description.exs"
  @license_file "license.exs"
  @name_file "name.exs"

  @doc """
  Generates a random app author name.

  Returns a string representing the full name of the app author.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

  """
  @spec author(Keyword.t()) :: String.t()
  defdelegate author(opts \\ [middle_name: false]), to: Person, as: :full_name

  @doc """
  Generates a short app description.

  Returns a string representing the app description.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

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
  Generates a random open-source license.

  Returns a random open-source license name selected from a predefined list based on
  [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: random_value(__MODULE__, @license_file, "licenses")

  @doc """
  Generates a random app name.

  Returns a string representing the app name, which is a combination of a first name and a last
  name.

  ## Options

  The accepted options are:

  - `:style` - Defines the case style of the app name.
  - `:locale` - Specifies the locale to use.

  The values for `:style` can be:

  - `nil` (default) - Uses the standard format, e.g., `"Neo Faker"`.
  - `:camel_case` - Uses camel case, e.g., `"neoFaker"`.
  - `:pascal_case` - Uses Pascal case, e.g., `"NeoFaker"`.
  - `:dashed` - Uses a dashed format, e.g., `"Neo-faker"`.
  - `:underscore` - Uses an underscore format, e.g., `"neo_faker"`.
  - `:single` - Uses a single-word format, e.g., `"Faker"`.

  The values for `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

      iex> NeoFaker.App.name(locale: :id_id)
      "Garuda Web"

  """
  @spec name(Keyword.t()) :: String.t()
  def name(opts \\ []) do
    locale = Keyword.get(opts, :locale)
    first_name = random_value(__MODULE__, @name_file, "first_names", locale: locale)
    last_name = random_value(__MODULE__, @name_file, "last_names", locale: locale)

    name_case({first_name, last_name}, Keyword.get(opts, :style))
  end

  @doc """
  Generates a semantic version number.

  Returns a version number following the Semantic Versioning (SemVer) standard. By default, it
  generates a core version (`MAJOR.MINOR.PATCH`).

  ## Options

  The accepted options are:

  - `:type` - Specifies the type of version format.

  The values for `:type` can be:

  - `nil` (default) - Uses core SemVer format (e.g., `"1.2.3"`).
  - `:pre_release` - Includes a pre-release label (e.g., `"1.2.3-beta.1")`.
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
    type = Keyword.get(opts, :type)
    core = semver_core()

    case type do
      nil -> core
      :pre_release -> "#{core}-#{semver_pre_release()}"
      :build -> "#{core}+#{semver_build_number()}"
      :pre_release_build -> "#{core}-#{semver_pre_release()}+#{semver_build_number()}"
      other -> raise ArgumentError, "Invalid semver type: #{inspect(other)}"
    end
  end

  @doc """
  Generates a simple version number.

  Returns a version number in the format `MAJOR.MINOR`.

  ## Examples

      iex> NeoFaker.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version do
    semver() |> String.split(".") |> Enum.take(2) |> Enum.join(".")
  end
end
