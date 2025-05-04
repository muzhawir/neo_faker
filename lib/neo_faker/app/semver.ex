defmodule NeoFaker.App.Semver do
  @moduledoc false

  @pre_release_label ~w[alpha beta rc]

  @doc """
  Generates a core semantic version number.
  Returns a randomly generated semantic version number following the `MAJOR.MINOR.PATCH` format.
  """
  @spec semver_core() :: String.t()
  def semver_core, do: Enum.map_join([0..9, 0..20, 1..30], ".", &Enum.random/1)

  @doc """
  Generates a random pre-release identifier.
  Returns a string in one of the following formats:

  - `"alpha.N"` - Early development stage.
  - `"beta.N"` - Testing phase before release.
  - `"rc.N"` - Release Candidate.
  """
  @spec semver_pre_release() :: String.t()
  def semver_pre_release, do: "#{Enum.random(@pre_release_label)}.#{Enum.random(1..10)}"

  @doc """
  Generates a build number based on the current date (YYYYMMDD).
  """
  @spec semver_build_number() :: String.t()
  def semver_build_number do
    NaiveDateTime.local_now()
    |> Date.add(Enum.random(-365..365))
    |> Date.to_string()
    |> String.replace("-", "")
  end
end
