defmodule NeoFaker.App.Semver do
  @moduledoc false

  @pre_release_labels ~w[alpha beta rc]

  @doc """
  Generates a random semantic version string in the `MAJOR.MINOR.PATCH` format.

  Each segment is randomly selected: MAJOR from 0–9, MINOR from 0–20, and PATCH from 1–30.
  """
  @spec semver_core() :: String.t()
  def semver_core do
    major = Enum.random(0..9)
    minor = Enum.random(0..20)
    patch = Enum.random(1..30)

    "#{major}.#{minor}.#{patch}"
  end

  @doc """
  Generates a random semantic version pre-release identifier.

  The result is a string in the format `"alpha.N"`, `"beta.N"`, or `"rc.N"`, where the label is
  randomly chosen from `"alpha"`, `"beta"`, or `"rc"`, and `N` is a random integer between 1 and
  10.
  """
  @spec semver_pre_release() :: String.t()
  def semver_pre_release do
    label = Enum.random(@pre_release_labels)
    n = Enum.random(1..10)

    "#{label}.#{n}"
  end

  @doc """
  Generates a semantic version build number string based on a randomly offset local date in
  `YYYYMMDD` format.

  The function takes the current local date, adds a random number of days between -365 and 365,
  and returns the resulting date as a string without dashes.
  """
  @spec semver_build_number() :: String.t()
  def semver_build_number do
    Date.utc_today()
    |> Date.add(Enum.random(-365..365))
    |> Date.to_string()
    |> String.replace("-", "")
  end
end
