defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times of day and time zone names.

  Every time-returning function returns a `Time` struct; use `Time.to_iso8601/1` if you
  need a string. "Now" means the current time in UTC, as returned by `now/0`.
  """
  @moduledoc since: "0.10.0"

  alias NeoFaker.Data
  alias NeoFaker.Helpers.Validator
  alias NeoFaker.Time.Generator
  alias NeoFaker.Time.Validator, as: TimeValidator

  @time_zone_file "time_zone.exs"

  @add_schema NimbleOptions.new!(unit: [type: {:in, [:hour, :minute, :second]}, default: :hour])

  @doc """
  Generates a random time offset from now by a number of units drawn from `range`.

  `range` defaults to `-24..24`. The result is truncated to whole seconds and wraps
  around midnight, so an offset of 25 hours lands one hour after now.

  Raises `ArgumentError` if `range` is not a non-empty range.

  ## Options

    * `:unit` (`:hour`, `:minute`, or `:second`) - the unit of the offset. Defaults to
      `:hour`.

  ## Examples

      iex> NeoFaker.Time.add()
      ~T[15:22:10]

      iex> NeoFaker.Time.add(-2..2, unit: :minute)
      ~T[07:23:10]

  """
  @spec add(Range.t(), keyword()) :: Time.t()
  def add(range \\ -24..24, opts \\ []) do
    Validator.validate_range!(range, "range")
    unit = opts |> NimbleOptions.validate!(@add_schema) |> Keyword.fetch!(:unit)

    Generator.add(range, unit)
  end

  @doc """
  Generates a random time between `start` and `finish`, inclusive.

  Defaults to the whole day, `~T[00:00:00]` to `~T[23:59:59]`. The result has second
  precision when both bounds do, and microsecond precision otherwise.

  Raises `ArgumentError` if either argument is not a `Time`, or if `start` is after
  `finish`.

  ## Examples

      iex> NeoFaker.Time.between()
      ~T[15:22:10]

      iex> NeoFaker.Time.between(~T[09:00:00], ~T[17:00:00])
      ~T[11:30:11]

  """
  @spec between(Time.t(), Time.t()) :: Time.t()
  def between(start \\ ~T[00:00:00], finish \\ ~T[23:59:59]) do
    TimeValidator.validate_time_order!(start, finish)
    Generator.between(start, finish)
  end

  @doc """
  Generates a random IANA time zone name, such as `"Asia/Makassar"`.

  ## Examples

      iex> NeoFaker.Time.time_zone()
      "Asia/Makassar"

  """
  @spec time_zone() :: String.t()
  def time_zone, do: Data.random_value(__MODULE__, @time_zone_file, "time_zone")

  @doc """
  Generates a random morning time, from `06:00:00` to `11:59:59`.

  ## Examples

      iex> NeoFaker.Time.morning()
      ~T[08:30:15]

  """
  @spec morning() :: Time.t()
  def morning, do: Generator.between(~T[06:00:00], ~T[11:59:59])

  @doc """
  Generates a random afternoon time, from `12:00:00` to `17:59:59`.

  ## Examples

      iex> NeoFaker.Time.afternoon()
      ~T[14:30:15]

  """
  @spec afternoon() :: Time.t()
  def afternoon, do: Generator.between(~T[12:00:00], ~T[17:59:59])

  @doc """
  Generates a random evening time, from `18:00:00` to `23:59:59`.

  ## Examples

      iex> NeoFaker.Time.evening()
      ~T[20:30:15]

  """
  @spec evening() :: Time.t()
  def evening, do: Generator.between(~T[18:00:00], ~T[23:59:59])

  @doc """
  Generates a random night time, from `00:00:00` to `05:59:59`.

  ## Examples

      iex> NeoFaker.Time.night()
      ~T[02:30:15]

  """
  @spec night() :: Time.t()
  def night, do: Generator.between(~T[00:00:00], ~T[05:59:59])

  @doc """
  Returns the current time in UTC, with microsecond precision.

  This function is not random. It is the reference point for `add/2`, and is equivalent
  to `Time.utc_now/0`.

  ## Examples

      iex> NeoFaker.Time.now()
      ~T[15:22:10.123456]

  """
  @spec now() :: Time.t()
  def now, do: Time.utc_now()
end
