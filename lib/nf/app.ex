defmodule Nf.App do
  @moduledoc """
  Provides functions for generating app metadata.

  This module includes functions to generate random app-related information, such as author names,
  app names, descriptions, versions, and licenses.
  """
  @moduledoc since: "0.4.0"

  import Nf.App.Utils
  import Nf.Helper, only: [get_random_value: 4, read_locale_file: 2]

  @typedoc "Random result in the form of a string or a list of strings"
  @type result :: String.t() | [String.t()]

  @module_name "app"

  @doc """
  Returns a random app author.

  The author name is a randomly generated full name.

  ## Examples

      iex> Nf.App.author()
      "José Valim"

      iex> Nf.App.author(2)
      ["Joe Armstrong", "José Valim"]

  """
  @spec author(integer()) :: result()
  def author(amount \\ 1) do
    get_random_value(@module_name, "author.exs", "authors", amount)
  end

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

      iex> Nf.App.name()
      "Neo Faker"

      iex> Nf.App.name(style: :camel_case)
      "neoFaker"

  """
  @spec name(Keyword.t()) :: String.t()
  def name(opts \\ []) do
    [first_name, last_name] =
      @module_name
      |> read_locale_file("name.exs")
      |> Map.values()
      |> Enum.map(&Enum.random/1)

    case Keyword.get(opts, :style) do
      nil -> "#{first_name} #{last_name}"
      :camel_case -> "#{String.downcase(first_name)}#{String.capitalize(last_name)}"
      :pascal_case -> "#{String.capitalize(first_name)}#{String.capitalize(last_name)}"
      :dashed -> "#{String.capitalize(first_name)}-#{last_name}"
      :underscore -> "#{String.downcase(first_name)}_#{String.downcase(last_name)}"
      :single -> [first_name, last_name] |> Enum.random() |> String.capitalize()
    end
  end

  @doc """
  Returns a short app description.

  The description provides a brief summary of the app.

  ## Examples

      iex> Nf.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> Nf.App.description(2)
      ["Elixir library for generating fake data in tests and development.",
      "Task automation tool for improving development workflows."]

  """
  @spec description(integer()) :: result()
  def description(amount \\ 1) do
    get_random_value(@module_name, "description.exs", "descriptions", amount)
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

      iex> Nf.App.semver()
      "1.2.3"

      iex> Nf.App.semver(:pre_release)
      "1.2.3-beta.1"

  """
  @spec semver(Keyword.t()) :: String.t()
  def semver(opts \\ []) do
    case Keyword.get(opts, :type) do
      nil -> semver_core()
      :pre_release -> "#{semver_core()}-#{semver_pre_release()}"
      :build -> "#{semver_core()}+#{semver_build_number()}"
      :pre_release_build -> "#{semver_core()}-#{semver_pre_release()}+#{semver_build_number()}"
    end
  end

  @doc """
  Returns a simple version number.

  This version format follows `MAJOR.MINOR`.

  ## Examples

      iex> Nf.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version, do: semver_core() |> String.split(".") |> Enum.take(2) |> Enum.join(".")

  @doc """
  Returns a random open-source license.

  The license is selected from a predefined list based on [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> Nf.App.license()
      "MIT License"

      iex> Nf.App.license(2)
      ["MIT License", "GNU General Public License v2.0"]

  """
  @spec license(integer()) :: result()
  def license(amount \\ 1) do
    get_random_value(@module_name, "license.exs", "licenses", amount)
  end
end
