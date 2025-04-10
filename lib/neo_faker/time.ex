defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times.

  This module provides utilities to generate random dates, including dates within a specific
  range and more.
  """
  @moduledoc since: "0.9.0"

  import NeoFaker.Time.Utils

  @doc """
  Generates a random time.

  Returns a time within the default range of 24 hours before and 24 hours after the current time.

  ## Options

  - `:unit` - Specifies the unit of time.
  - `:format` - Specifies the format of the date.

  The values for `:unit` can be:

  - `:hour` - Returns the time in hours (default).
  - `:minute` - Returns the time in minutes.
  - `:second` - Returns the time in seconds.

  The values for `:format` can be:

  - `:date` - Returns the date in `Date` format (default).
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
    format = Keyword.get(opts, :format, :time)

    random_add_time(range, unit, format)
  end
end
