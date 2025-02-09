defmodule Nf.App.Utils do
  @moduledoc false

  @doc """
  Generates a core semantic version number.

  The version follows the `MAJOR.MINOR.PATCH` format as defined by the
  [Semantic Versioning 2.0.0](https://semver.org/) specification.
  """
  @spec semver_core() :: String.t()
  def semver_core do
    {major, minor, patch} = {0..10, 0..20, 1..30}

    Enum.map_join([major, minor, patch], ".", &Enum.random/1)
  end

  @doc """
  Generates a random pre-release identifier.

  The pre-release identifier is typically used to indicate unstable versions and follows the
  format `"alpha.N"`, `"beta.N"`, or `"rc.N"`.
  """
  @spec semver_pre_release() :: String.t()
  def semver_pre_release do
    identifier = Enum.random(~w[alpha beta rc])

    "#{identifier}.#{Enum.random(1..10)}"
  end

  @doc """
  Generates a build number based on the current date.

  The build number is formatted as `YYYYMMDD`, providing a timestamp for identifying builds.
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
