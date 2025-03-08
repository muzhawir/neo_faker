defmodule NeoFaker.App do
  @moduledoc """
  Provides functions for generating app metadata.

  This module offers functions to generate random app-related information, including
  author names, app names, descriptions, versions, and licenses.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Util
  import NeoFaker.Helper.Generator, only: [random: 4]

  alias NeoFaker.Person

  @module __MODULE__
  @description_file "description.exs"
  @license_file "license.exs"
  @name_file "name.exs"

  @doc """
  Generates a random app author name.

  The author name is randomly generated as a full name.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

  """
  @spec author(Keyword.t()) :: String.t()
  defdelegate author(opts \\ [middle_name: false]), to: Person, as: :full_name

  @doc """
  Generates a short app description.

  The description provides a brief summary of the app's purpose.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `"default"`.
  - `"id_id"` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> NeoFaker.App.description(locale: "id_id")
      "Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."

  """
  @spec description(Keyword.t()) :: String.t()
  def description(opts \\ []), do: random(@module, @description_file, "descriptions", opts)

  @doc """
  Generates a random open-source license.

  The license is randomly selected from a predefined list based on
  [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: random(@module, @license_file, "licenses", [])

  @doc """
  Generates a random app name.

  By default, the app name follows a standard format. You can specify a different case style
  using the `:style` option.

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

  - `nil` - Uses the default locale `"default"`.
  - `"id_id"` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

      iex> NeoFaker.App.name(locale: "id_id")
      "Garuda Web"

  """
  @spec name(Keyword.t()) :: String.t()
  def name(opts \\ []) do
    style = Keyword.get(opts, :style)
    locale = Keyword.get(opts, :locale)
    first_name = random(@module, @name_file, "first_names", locale: locale)
    last_name = random(@module, @name_file, "last_names", locale: locale)

    name_case({first_name, last_name}, style)
  end

  @doc """
  Returns a semantic version number.

  The generated version number follows the Semantic Versioning (SemVer) standard. By default, it
  generates a core version (`MAJOR.MINOR.PATCH`). Additional versioning details can be specified
  using the `:type` option.

  ## Options

  The accepted options are:

  - `:type` - Specifies the type of version format.

  The values for `:type` can be:

  - `nil` (default) - Uses core SemVer format, e.g., `"1.2.3"`.
  - `:pre_release` - Includes a pre-release label, e.g., `"1.2.3-beta.1"`.
  - `:build` - Includes a build metadata label, e.g., `"1.2.3+20250325"`.
  - `:pre_release_build` - Includes both pre-release and build metadata, e.g.,
    `"1.2.3-rc.1+20250325"`.

  ## Examples

      iex> NeoFaker.App.semver()
      "1.2.3"

      iex> NeoFaker.App.semver(:pre_release)
      "1.2.3-beta.1"

  """
  @spec semver(Keyword.t()) :: String.t()
  defdelegate semver(opts \\ []), to: NeoFaker.App.Util, as: :semver

  @doc """
  Returns a simple version number.

  This version format follows `MAJOR.MINOR`.

  ## Examples

      iex> NeoFaker.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version do
    semver()
    |> String.split(".")
    |> Enum.take(2)
    |> Enum.join(".")
  end
end
