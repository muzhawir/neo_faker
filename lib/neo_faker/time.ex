defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times.

  This module provides utilities to generate random times, including times within a specific
  range and more.
  """
  @moduledoc since: "0.10.0"

  import NeoFaker.Time.Utils

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

  - `:sigil` - Returns the date in sigil `~T` format (default).
  - `:iso8601` - Returns the date in ISO 8601 format.

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
    unit = Keyword.get(opts, :unit, :hour)
    format = Keyword.get(opts, :format, :sigil)

    random_add_time(range, unit, format)
  end

  @doc """
  Generates a random time between two times.

  Returns a random time between the specified start and finish times.

  ## Options

  - `:format` - Specifies the format of the date.

  The values for `:format` can be:

  - `:sigil` - Returns the date in sigil `~T` format (default).
  - `:iso8601` - Returns the date in ISO 8601 format.

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
    format = Keyword.get(opts, :format, :sigil)

    random_between_time(start, finish, format)
  end
end
