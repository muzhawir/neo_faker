defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating app metadata.

  This module provides utilities to generate random app-related information, including author
  names, app names, descriptions, versions, and licenses.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Name
  import NeoFaker.App.Semver
  import NeoFaker.Data.Generator, only: [random_data: 3, random_data: 4]

  alias NeoFaker.Person

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
    random_data(__MODULE__, @description_file, "descriptions", opts)
  end

  @doc """
  Generates a random open-source license.

  The license is randomly selected from a predefined list based on
  [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: random_data(__MODULE__, @license_file, "licenses")

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
    first_name = random_data(__MODULE__, @name_file, "first_names", locale: locale)
    last_name = random_data(__MODULE__, @name_file, "last_names", locale: locale)

    name_case({first_name, last_name}, Keyword.get(opts, :style))
  end

  
  
  @doc """
Generates a random semantic version string following the SemVer standard.

By default, returns a core version in the format `MAJOR.MINOR.PATCH`. The `:type` option allows inclusion of pre-release and/or build metadata.

## Options

  - `:type` (optional) — Specifies the version format:
    - `nil` (default): Core version (e.g., `"1.2.3"`).
    - `:pre_release`: Adds a pre-release label (e.g., `"1.2.3-beta.1"`).
    - `:build`: Adds build metadata (e.g., `"1.2.3+20250325"`).
    - `:pre_release_build`: Includes both pre-release and build metadata (e.g., `"1.2.3-rc.1+20250325"`).

## Examples

    iex> NeoFaker.App.semver()
    "1.2.3"

    iex> NeoFaker.App.semver(type: :pre_release)
    "1.2.3-beta.1"
"""
@spec semver(Keyword.t()) :: String.t()
def semver(opts \\ [])
  @doc """
Generates a semantic version string in the format `MAJOR.MINOR.PATCH`.

Returns a core semantic version without pre-release or build metadata.
"""
def semver([]), do: semver_core()
  @doc """
Generates a semantic version string with a pre-release label, following the format `MAJOR.MINOR.PATCH-PRERELEASE`.

The pre-release label is appended to the core semantic version, producing values like `1.2.3-beta.1`.
"""
def semver(type: :pre_release), do: "#{semver_core()}-#{semver_pre_release()}"
  @doc """
Generates a semantic version string with build metadata in the format `MAJOR.MINOR.PATCH+BUILD`.

The build metadata is appended to the core semantic version, following the SemVer specification.
"""
def semver(type: :build), do: "#{semver_core()}+#{semver_build_number()}"

  @doc """
  Generates a semantic version string with both pre-release and build metadata, following the format `MAJOR.MINOR.PATCH-PRERELEASE+BUILD`.
  
  Returns a version string such as `1.2.3-rc.1+20250325`.
  """
  def semver(type: :pre_release_build) do
    "#{semver_core()}-#{semver_pre_release()}+#{semver_build_number()}"
  end

  
  
  @doc """
Returns a version string in `MAJOR.MINOR` format.

Generates a simplified version number by extracting the major and minor components from a full semantic version.

## Examples

    iex> NeoFaker.App.version()
    "1.2"

"""
def version, do: [] |> semver() |> String.split(".") |> Enum.take(2) |> Enum.join(".")
end
