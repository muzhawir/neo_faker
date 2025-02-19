defmodule NeoFaker.App do
  @moduledoc """
  Provides functions for generating app metadata.

  This module includes functions to generate random app-related information, such as author names,
  app names, descriptions, versions, and licenses.
  """
  @moduledoc since: "0.4.0"

  import NeoFaker.App.Utils
  import NeoFaker.Helper.Locale

  @typedoc "Random result in the form of a string or a list of strings."
  @type result :: String.t() | [String.t()]

  @module __MODULE__

  @doc """
  Returns a random app author.

  The author name is a randomly generated full name.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

      iex> NeoFaker.App.author(2)
      ["Joe Armstrong", "José Valim"]

  """
  @spec author(integer()) :: result()
  def author(amount \\ 1) do
    random_value(@module, "author.exs", "authors", amount)
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

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(2)
      ["Neo Faker", "Ignite Core"]

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

  """
  @spec name(integer(), keyword()) :: result()
  def name(amount \\ 1, opts \\ [])

  def name(1, opts) do
    style = Keyword.get(opts, :style, nil)

    @module |> load_app_names_cache(1) |> name_case(type: style)
  end

  def name(amount, opts) when amount == -1 or amount > 1 do
    {first_names_list, last_names_list} = load_app_names_cache(@module, amount)
    style = Keyword.get(opts, :style, nil)

    for {first_name, last_name} <- Enum.zip(first_names_list, last_names_list) do
      name_case({first_name, last_name}, type: style)
    end
  end

  @doc """
  Returns a short app description.

  The description provides a brief summary of the app.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> NeoFaker.App.description(2)
      ["Elixir library for generating fake data in tests and development.",
      "Task automation tool for improving development workflows."]

  """
  @spec description(integer()) :: result()
  def description(amount \\ 1) do
    random_value(@module, "description.exs", "descriptions", amount)
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

  @doc """
  Returns a random open-source license.

  The license is selected from a predefined list based on [ChooseALicense](https://choosealicense.com/appendix).

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

      iex> NeoFaker.App.license(2)
      ["MIT License", "GNU General Public License v2.0"]

  """
  @spec license(integer()) :: result()
  def license(amount \\ 1) do
    random_value(@module, "license.exs", "licenses", amount)
  end
end
