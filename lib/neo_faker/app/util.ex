defmodule NeoFaker.App.Util do
  @moduledoc false

  @pre_release_label ~w[alpha beta rc]

  @doc """
  Converts a name into the specified case format.

  This function takes a tuple containing a first name and a last name, then formats it
  according to the given case style.
  """
  @spec name_case({String.t(), String.t()}, atom()) :: String.t()
  def name_case({first_name, last_name}, nil), do: "#{first_name} #{last_name}"

  def name_case({first_name, last_name}, :camel_case) do
    "#{String.downcase(first_name)}#{String.capitalize(last_name)}"
  end

  def name_case({first_name, last_name}, :pascal_case) do
    "#{String.capitalize(first_name)}#{String.capitalize(last_name)}"
  end

  def name_case({first_name, last_name}, :dashed) do
    "#{String.capitalize(first_name)}-#{last_name}"
  end

  def name_case({first_name, last_name}, :underscore) do
    "#{String.downcase(first_name)}_#{String.downcase(last_name)}"
  end

  def name_case({first_name, last_name}, :single) do
    [first_name, last_name] |> Enum.random() |> String.capitalize()
  end

  @doc """
  Generates a core semantic version number.

  This function returns a randomly generated semantic version number following
  the `MAJOR.MINOR.PATCH` format as defined by the
  [Semantic Versioning 2.0.0](https://semver.org/) specification.
  """
  @spec semver_core() :: String.t()
  def semver_core, do: Enum.map_join([0..9, 0..20, 1..30], ".", &Enum.random/1)

  @doc """
  Generates a random pre-release identifier.

  This function returns a randomly generated pre-release identifier
  following the Semantic Versioning 2.0.0 specification.

  Pre-release identifiers are used to indicate unstable versions
  and typically follow one of these formats:

  - `"alpha.N"` - Represents an early development stage.
  - `"beta.N"` - Represents a testing phase before release.
  - `"rc.N"` - Stands for "Release Candidate," meaning it is nearly final.

  `N` is a positive integer that represents the version sequence.
  """
  @spec semver_pre_release() :: String.t()
  def semver_pre_release, do: "#{Enum.random(@pre_release_label)}.#{Enum.random(1..10)}"

  @doc """
  Generates a build number based on the current date.

  This function returns a build number in the format `YYYYMMDD`, where:

  - `YYYY` is the four-digit year.
  - `MM` is the two-digit month (01-12).
  - `DD` is the two-digit day (01-31).

  This format provides a simple way to timestamp builds, making it easier to track versions over
  time.
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
