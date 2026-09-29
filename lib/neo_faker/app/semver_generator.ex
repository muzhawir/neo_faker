defmodule NeoFaker.App.SemverGenerator do
  @moduledoc false

  @pre_release_labels ~w[alpha beta rc]

  @doc """
  Returns a random `MAJOR.MINOR.PATCH` string (major `0..9`, minor `0..20`, patch `1..30`).
  """
  @spec core() :: String.t()
  def core, do: "#{major_minor()}.#{Enum.random(1..30)}"

  @doc """
  Returns a random `MAJOR.MINOR` string, drawn from the same ranges as `core/0`.
  """
  @spec major_minor() :: String.t()
  def major_minor, do: "#{Enum.random(0..9)}.#{Enum.random(0..20)}"

  @doc """
  Returns a random pre-release identifier such as `"beta.3"`: `alpha`, `beta`, or `rc`,
  followed by a number from `1` to `10`.
  """
  @spec pre_release() :: String.t()
  def pre_release, do: "#{Enum.random(@pre_release_labels)}.#{Enum.random(1..10)}"

  @doc """
  Returns random build metadata: a `YYYYMMDD` date within a year of today (UTC).
  """
  @spec build() :: String.t()
  def build do
    Date.utc_today()
    |> Date.add(Enum.random(-365..365))
    |> Calendar.strftime("%Y%m%d")
  end
end
