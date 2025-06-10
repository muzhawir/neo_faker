defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times.

  This module provides utilities to generate random times, including times within a specific
  range and more.
  """
  @moduledoc since: "0.10.0"

  import NeoFaker.Time.Add
  import NeoFaker.Time.Between

  alias NeoFaker.Data.Generator

  @time_zone_file "time_zone.exs"

  @doc """
  Generates a random time.

  Returns a time within the default range of 24 hours before and 24 hours after the current time.

  ## Options

  - `:unit` - Specifies the unit of time range.
  - `:format` - Specifies the format of the date.

  The values for `:unit` can be:

  - `:hour` - Returns the time in hours (default).
  - `:minute` - Returns the time in minutes.
  - `:second` - Returns the time in seconds.

  The values for `:format` can be:

  - `:struct` - Returns a `Time` struct (default).
  - `:iso8601` - Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Time.add()
      ~T[15:22:10]

      iex> NeoFaker.Time.add(-2..2, unit: :minute)
      ~T[07:23:10]

      iex> NeoFaker.Time.add(0..10, format: :iso8601)
      "15:22:10"

  """
  @spec add(Range.t(), Keyword.t()) :: Time.t() | String.t()
  def add(range \\ -24..24, opts \\ []) do
    random_add_time(
      range,
      Keyword.get(opts, :unit, :hour),
      Keyword.get(opts, :format, :struct)
    )
  end

  @doc """
  Generates a random time between two times.

  Returns a random time between the specified start and finish times.

  ## Options

  - `:format` - Specifies the format of the time.

  The values for `:format` can be:

  - `:struct` - Returns a `Time` struct (default).
  - `:iso8601` - Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Time.between()
      ~T[15:22:10]

      iex> NeoFaker.Time.between(~T[00:00:00], ~T[23:59:59])
      ~T[19:30:11]

      iex> NeoFaker.Time.between(~T[00:00:00], ~T[23:59:59], format: :iso8601)
      "15:22:10"

  """
  @spec between(Time.t(), Time.t(), Keyword.t()) :: Time.t() | String.t()
  def between(start \\ ~T[00:00:00], finish \\ ~T[23:59:59], opts \\ []) do
    random_between_time(start, finish, Keyword.get(opts, :format, :struct))
  end

  @doc """
  Generates a random time zone.

  Returns a random time zone from a predefined list of time zones.

  ## Examples

      iex> NeoFaker.Time.time_zone()
      "Asia/Makassar"

  """
  @doc since: "0.12.0"
  @spec time_zone() :: String.t()
  def time_zone, do: Generator.random_value(__MODULE__, @time_zone_file, "time_zone")
end
