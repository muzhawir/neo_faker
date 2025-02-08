defmodule Nf.App do
  @moduledoc """
  Functions for generating information about app metadata.
  """
  @moduledoc since: "0.4.0"

  import Nf.App.Utils

  @typedoc "Semantic version type"
  @type semver_type :: nil | :core | :pre_release | :build | :pre_release_build

  # TODO: complete the person generator module first and then create this author function
  #
  # def author do
  #   "John Doe"
  # end

  def name do
    "NeoFaker"
  end

  @doc """
  Generate a semantic version number.

  Returns a semantic version number like `1.2.3`.

  ## Arguments

  The accepted arguments are:

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
  @spec semver(semver_type()) :: String.t()
  def semver(type \\ nil) do
    case type do
      nil -> semver_core()
      :pre_release -> "#{semver_core()}-#{semver_pre_release()}"
      :build -> "#{semver_core()}+#{semver_build_number()}"
      :pre_release_build -> "#{semver_core()}-#{semver_pre_release()}+#{semver_build_number()}"
    end
  end

  @doc """
  Generate a simple version number.

  Returns a simple version number like `1.2` (major.minor).

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
  def license, do: read_license_file() |> Map.get("licenses") |> Enum.random()
end
