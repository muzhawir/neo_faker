defmodule Nf.App do
  @moduledoc """
  Functions for generating information about app metadata.
  """
  @moduledoc since: "0.4.0"
  import Nf.App.Utils

  alias Nf.Helper

  # TODO: complete the person generator module first and then create this author function
  #
  # def author do
  #   "John Doe"
  # end

  @doc """
  Generate an app description.

  Returns a short app description.

  ## Examples

      iex> Nf.App.description()
      "Fake data generator for Elixir, useful for testing, database seeding, and development."

  """
  @spec description() :: String.t()
  def description do
    json_path = ["app"]

    json_path
    |> Helper.read_json_file!("description.json")
    |> Map.get("descriptions")
    |> Enum.random()
  end

  @doc """
  Generate a semantic version number.

  Returns a semantic version number like `1.2.3`.

  ## Option

  The accepted option is:
  - `:type` - specifies the type of semver version

  The values for :type can be:

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
    json_path = ["app"]

    json_path
    |> Helper.read_json_file!("license.json")
    |> Map.get("licenses")
    |> Enum.random()
  end
end
