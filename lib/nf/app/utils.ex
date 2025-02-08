defmodule Nf.App.Utils do
  @moduledoc false
  @moduledoc since: "0.4.0"

  @doc """
  Generate a semver number.

  Returns a semantic version number like `1.2.3`.
  """
  @spec semver_core() :: String.t()
  def semver_core do
    {major, minor, patch} = {0..10, 0..20, 1..30}

    Enum.map_join([major, minor, patch], ".", &Enum.random/1)
  end

  @doc """
  Generate a pre-release identifier.

  Returns a pre-release identifier like `alpha.1`, `beta.2`, or `rc.3`.
  """
  @spec semver_pre_release() :: String.t()
  def semver_pre_release do
    identifier = Enum.random(~w[alpha beta rc])

    "#{identifier}.#{Enum.random(1..10)}"
  end

  @doc """
  Generate a build number.

  Returns a build number based on the date format `YYYYMMDD`.
  """
  @spec semver_build_number() :: String.t()
  def semver_build_number do
    day_range = Enum.random(-365..365)

    Date.utc_today()
    |> Date.add(day_range)
    |> Date.to_string()
    |> String.replace("-", "")
  end
end
