defmodule NeoFaker.App.Semver do
  @moduledoc false

  @pre_release_label ~w[alpha beta rc]

  
  
  @doc """
Generates a random semantic version string in the `MAJOR.MINOR.PATCH` format.

Each segment is randomly selected: MAJOR from 0–9, MINOR from 0–20, and PATCH from 1–30.
"""
def semver_core, do: Enum.map_join([0..9, 0..20, 1..30], ".", &Enum.random/1)

  
  
  @doc """
Generates a random semantic version pre-release identifier.

The result is a string in the format `"alpha.N"`, `"beta.N"`, or `"rc.N"`, where the label is randomly chosen from `"alpha"`, `"beta"`, or `"rc"`, and `N` is a random integer between 1 and 10.
"""
def semver_pre_release, do: "#{Enum.random(@pre_release_label)}.#{Enum.random(1..10)}"

  
  
  @doc """
  Generates a semantic version build number string based on a randomly offset local date in `YYYYMMDD` format.
  
  The function takes the current local date, adds a random number of days between -365 and 365, and returns the resulting date as a string without dashes.
  """
  def semver_build_number do
    NaiveDateTime.local_now()
    |> Date.add(Enum.random(-365..365))
    |> Date.to_string()
    |> String.replace("-", "")
  end
end
