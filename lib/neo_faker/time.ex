defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times.

  Provides utilities to generate random times, including times relative to now,
  times within a specific range, time zones, and named periods (morning, afternoon,
  evening, night). Every function returns a `Time` struct; call `Time.to_iso8601/1`
  yourself if you need a string.
  """
  @moduledoc since: "0.10.0"

  alias NeoFaker.Data
  alias NeoFaker.Time.Generator, as: TimeGenerator
  alias NeoFaker.Time.Validator, as: TimeValidator

  @time_zone_file "time_zone.exs"

  @time_range -24..24
  @midnight ~T[00:00:00]
  @end_of_day ~T[23:59:59]

  @add_schema NimbleOptions.new!(unit: [type: {:in, [:hour, :minute, :second]}, default: :hour])

  @doc """
  Generates a random time offset from now.

  Adds a random number of units (hours by default) drawn from `range` to the current time.
  `range` defaults to `-24..24`.

  ## Options

    * `:unit` (`:hour`, `:minute`, or `:second`) - the unit of the range. Defaults to `:hour`.

  ## Examples

      iex> NeoFaker.Time.add()
      ~T[15:22:10]

      iex> NeoFaker.Time.add(-2..2, unit: :minute)
      ~T[07:23:10]

  """
  @spec add(Range.t(), keyword()) :: Time.t()
  def add(range \\ @time_range, opts \\ []) do
    TimeValidator.validate_range!(range)
    opts = NimbleOptions.validate!(opts, @add_schema)

    TimeGenerator.add(range, Keyword.fetch!(opts, :unit))
  end

  @doc """
  Generates a random time between two times.

  Both `start` and `finish` are inclusive. Defaults to the full day
  (`~T[00:00:00]`–`~T[23:59:59]`).

  ## Examples

      iex> NeoFaker.Time.between()
      ~T[15:22:10]

      iex> NeoFaker.Time.between(~T[00:00:00], ~T[23:59:59])
      ~T[19:30:11]

  """
  @spec between(Time.t(), Time.t()) :: Time.t()
  def between(start \\ @midnight, finish \\ @end_of_day) do
    TimeValidator.validate_time_order!(start, finish)

    TimeGenerator.between(start, finish)
  end

  @doc """
  Generates a random time zone string.

  Returns an IANA time zone name from a predefined list, such as
  `"Asia/Makassar"` or `"America/New_York"`.

  ## Examples

      iex> NeoFaker.Time.time_zone()
      "Asia/Makassar"

  """
  @spec time_zone() :: String.t()
  def time_zone do
    Data.random_value(__MODULE__, @time_zone_file, "time_zone")
  end

  @doc """
  Generates a random morning time (06:00–11:59).

  ## Examples

      iex> NeoFaker.Time.morning()
      ~T[08:30:15]

  """
  @spec morning() :: Time.t()
  def morning, do: between(~T[06:00:00], ~T[11:59:59])

  @doc """
  Generates a random afternoon time (12:00–17:59).

  ## Examples

      iex> NeoFaker.Time.afternoon()
      ~T[14:30:15]

  """
  @spec afternoon() :: Time.t()
  def afternoon, do: between(~T[12:00:00], ~T[17:59:59])

  @doc """
  Generates a random evening time (18:00–23:59).

  ## Examples

      iex> NeoFaker.Time.evening()
      ~T[20:30:15]

  """
  @spec evening() :: Time.t()
  def evening, do: between(~T[18:00:00], ~T[23:59:59])

  @doc """
  Generates a random night time (00:00–05:59).

  ## Examples

      iex> NeoFaker.Time.night()
      ~T[02:30:15]

  """
  @spec night() :: Time.t()
  def night, do: between(~T[00:00:00], ~T[05:59:59])

  @doc """
  Returns the current UTC time.

  A thin convenience wrapper around `Time.utc_now/0`.

  ## Examples

      iex> NeoFaker.Time.now()
      ~T[15:22:10.123456]

  """
  @spec now() :: Time.t()
  def now, do: Time.utc_now()
end
