defmodule Nf.App do
  @moduledoc """
  Functions for generating information about app metadata.
  """
  @moduledoc since: "0.4.0"

  import Nf.App.Utils

  alias Nf.Helper

  @app_directory ["app"]

  @doc """
  Generate an app author.

  Returns a full name of an app author.

  ## Examples

      iex> Nf.App.author()
      "José Valim"

  """
  @spec author() :: String.t()
  def author do
    @app_directory
    |> Helper.read_exs_file!("author.exs")
    |> Map.get("authors")
    |> Enum.random()
  end

  @doc """
  Generate an app name.

  Returns an app name.

  ## Options

  The accepted options are:

  - `:style` - specifies the style of the app name

  The values for `:style` can be:

  - `nil` - uses the default style like `Neo Faker` (default)
  - `:camel_case` - uses camel case like `neoFaker`
  - `:pascal_case` - uses pascal case like `NeoFaker`
  - `:dashed` - uses dashed style like `Neo-faker`
  - `:single` - uses a single word like `Faker`

  ## Examples

      iex> Nf.App.name()
      "Neo Faker"

      iex> Nf.App.name(style: :camel_case)
      "neoFaker"

      iex> Nf.App.name(style: :pascal_case)
      "NeoFaker"

      iex> Nf.App.name(style: :dashed)
      "Neo-faker"

      iex> Nf.App.name(style: :single)
      "Faker"

  """
  @spec name(Keyword.t()) :: String.t()
  def name(opts \\ []) do
    [first_name, last_name] =
      @app_directory
      |> Helper.read_exs_file!("name.exs")
      |> Map.values()
      |> Enum.map(&Enum.random/1)

    case Keyword.get(opts, :style) do
      nil -> "#{first_name} #{last_name}"
      :camel_case -> "#{String.downcase(first_name)}#{String.capitalize(last_name)}"
      :pascal_case -> "#{String.capitalize(first_name)}#{String.capitalize(last_name)}"
      :dashed -> "#{String.capitalize(first_name)}-#{last_name}"
      :single -> [first_name, last_name] |> Enum.random() |> String.capitalize()
    end
  end

  @doc """
  Generate an app description.

  Returns a short app description.

  ## Examples

      iex> Nf.App.description()
      "Fake data generator for Elixir, useful for testing, database seeding, and development."

  """
  @spec description() :: String.t()
  def description do
    @app_directory
    |> Helper.read_exs_file!("description.exs")
    |> Map.get("descriptions")
    |> Enum.random()
  end

  @doc """
  Generate a semantic version number.

  Returns a semantic version number like `1.2.3`.

  ## Options

  The accepted options is:
  - `:type` - specifies the type of semver version

  The values for `:type` can be:

  - `nil` - uses semver core like `1.2.3` (default)
  - `:pre_release` - uses semver core with pre-release label like `1.2.3-alpha.1`
  - `:build` - uses semver core with build number label like `1.2.3+20250325`
  - `:pre_release_build` - uses  semver core with pre-release and build number label like
    `1.2.3-alpha.1+20250325`

  ## Examples

      iex> Nf.App.semver()
      "1.2.3"

      iex> Nf.App.semver(:pre_release)
      "1.2.3-alpha.1"

      iex> Nf.App.semver(:build)
      "1.2.3+20250325"

      iex> Nf.App.semver(:pre_release_build)
      "1.2.3-alpha.1+20250325"

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
  Generate a simple version number.

  Returns a simple version number like `1.2`.

  ## Examples

      iex> Nf.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version, do: semver_core() |> String.split(".") |> Enum.take(2) |> Enum.join(".")

  @doc """
  Generate an open source license.

  Returns an open source license. License lists taken from
  [https://choosealicense.com](https://choosealicense.com/appendix).

  ## Examples

      iex> Nf.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license do
    @app_directory
    |> Helper.read_exs_file!("license.exs")
    |> Map.get("licenses")
    |> Enum.random()
  end
end
