defmodule NeoFaker.App.Semver do
  @moduledoc false

  @pre_release_label ~w[alpha beta rc]

  @doc """
  Generates a semantic version number.

  This function delegates the call to `NeoFaker.App.semver/1`.
  """
  @spec semver(Keyword.t()) :: String.t()
  def semver([]), do: semver_core()
  def semver(type: :pre_release), do: "#{semver_core()}-#{semver_pre_release()}"
  def semver(type: :build), do: "#{semver_core()}+#{semver_build_number()}"

  def semver(type: :pre_release_build) do
    "#{semver_core()}-#{semver_pre_release()}+#{semver_build_number()}"
  end

  # Generates a core semantic version number.
  # Returns a randomly generated semantic version number following the `MAJOR.MINOR.PATCH` format.
  defp semver_core, do: Enum.map_join([0..9, 0..20, 1..30], ".", &Enum.random/1)

  # Generates a random pre-release identifier.
  # Returns a string in one of the following formats:
  # - `"alpha.N"` - Early development stage.
  # - `"beta.N"` - Testing phase before release.
  # - `"rc.N"` - Release Candidate.
  defp semver_pre_release, do: "#{Enum.random(@pre_release_label)}.#{Enum.random(1..10)}"

  # Generates a build number based on the current date (YYYYMMDD).
  defp semver_build_number do
    day_range = Enum.random(-365..365)

    NaiveDateTime.local_now()
    |> Date.add(day_range)
    |> Date.to_string()
    |> String.replace("-", "")
  end
end
