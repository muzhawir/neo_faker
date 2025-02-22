defmodule NeoFaker.App do
  @moduledoc """
  Provides functions for generating app metadata.

  This module includes functions to generate random app-related information, such as author names,
  app names, descriptions, versions, and licenses.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Utils
  import NeoFaker.Helper.Locale

  @module __MODULE__
  @authors_file "author.exs"
  @descriptions_file "description.exs"
  @licenses_file "license.exs"
  @names_file "name.exs"

  @doc """
  Returns a random app author.

  The author name is a randomly generated full name.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

  """
  @spec author() :: String.t()
  def author, do: random_value(@module, @authors_file, "authors")

  @doc """
  Returns a short app description.

  The description provides a brief summary of the app.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

  """
  @spec description() :: String.t()
  def description, do: random_value(@module, @descriptions_file, "descriptions")

  @doc """
  Returns a random open-source license.

  The license is selected from a predefined list based on [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: random_value(@module, @licenses_file, "licenses")

  @doc """
  Returns a random app name.

  By default, the app name is generated in a standard format. A different naming style can be
  specified using the `:style` option.

  ## Options

  The accepted options are:

  - `:style` - Specifies the style of the app name.

  The values for `:style` can be:

  - `nil` (default) - Uses the standard format, e.g., `"Neo Faker"`.
  - `:camel_case` - Uses camel case, e.g., `"neoFaker"`.
  - `:pascal_case` - Uses Pascal case, e.g., `"NeoFaker"`.
  - `:dashed` - Uses a dashed style, e.g., `"Neo-faker"`.
  - `:underscore` - Uses an underscore style, e.g., `"neo_faker"`.
  - `:single` - Uses a single-word format, e.g., `"Faker"`.

  ## Examples

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

  """
  def name(type \\ [style: nil]) do
    names =
      @module
      |> current_module()
      |> load_persistent_term(@names_file, "names")
      |> Map.new()

    first_name_list = names |> Map.get("first_names") |> Enum.random()
    last_name_list = names |> Map.get("last_names") |> Enum.random()

    name_case({first_name_list, last_name_list}, type)
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
  - `:pre_release_build` - Includes both pre-release and build metadata, e.g., `"1.2.3-rc.1+20250325"`.

  ## Examples

      iex> NeoFaker.App.semver()
      "1.2.3"

      iex> NeoFaker.App.semver(:pre_release)
      "1.2.3-beta.1"

  """
  @spec semver(Keyword.t()) :: String.t()
  def semver(opts \\ [])
  def semver([]), do: semver_core()
  def semver(type: :pre_release), do: "#{semver_core()}-#{semver_pre_release()}"
  def semver(type: :build), do: "#{semver_core()}+#{semver_build_number()}"

  def semver(type: :pre_release_build) do
    "#{semver_core()}-#{semver_pre_release()}+#{semver_build_number()}"
  end

  @doc """
  Returns a simple version number.

  This version format follows `MAJOR.MINOR`.

  ## Examples

      iex> NeoFaker.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version, do: semver_core() |> String.split(".") |> Enum.take(2) |> Enum.join(".")
end
