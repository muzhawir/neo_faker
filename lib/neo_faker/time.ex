defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times.

  Provides utilities to generate random times, including times relative to now,
  times within a specific range, time zones, and named periods (morning, afternoon,
  evening, night). All functions support both `Time` struct and ISO 8601 string output.
  """
  @moduledoc since: "0.10.0"

  alias NeoFaker.Data
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Time.Generator, as: TimeGenerator
  alias NeoFaker.Time.Validator, as: TimeValidator

  @time_zone_file "time_zone.exs"

  @time_range -24..24
  @midnight ~T[00:00:00]
  @end_of_day ~T[23:59:59]

  @doc """
  Generates a random time offset from now.

  Adds a random number of units (hours by default) drawn from `range` to the
  current time. The default range is `-24..24`.

  ## Options

  - `:unit` - Unit of the range. One of `:hour` (default), `:minute`, or `:second`.
  - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.add()
      ~T[15:22:10]

      iex> NeoFaker.Time.add(-2..2, unit: :minute)
      ~T[07:23:10]

      iex> NeoFaker.Time.add(0..10, format: :iso8601)
      "15:22:10"

  """
  @spec add(Range.t(), Keyword.t()) :: Time.t() | String.t()
  def add(range \\ @time_range, opts \\ []) do
    TimeValidator.validate_range!(range)
    unit = TimeValidator.get_and_validate_unit!(opts)
    format = TimeValidator.get_and_validate_format!(opts)

    time = TimeGenerator.add(range, unit, :struct)
    Formatter.format_time(time, format)
  end

  @doc """
  Generates a random time between two times.

  Both `start` and `finish` are inclusive. Defaults to the full day
  (`~T[00:00:00]`–`~T[23:59:59]`).

  ## Parameters

  - `start` - Start time, inclusive. Defaults to `~T[00:00:00]`.
  - `finish` - End time, inclusive. Defaults to `~T[23:59:59]`.
  - `opts` - Keyword list of options:
    - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.between()
      ~T[15:22:10]

      iex> NeoFaker.Time.between(~T[00:00:00], ~T[23:59:59])
      ~T[19:30:11]

      iex> NeoFaker.Time.between(~T[00:00:00], ~T[23:59:59], format: :iso8601)
      "15:22:10"

  """
  @spec between(Time.t(), Time.t(), Keyword.t()) :: Time.t() | String.t()
  def between(start \\ @midnight, finish \\ @end_of_day, opts \\ []) do
    TimeValidator.validate_time_order!(start, finish)
    format = TimeValidator.get_and_validate_format!(opts)

    time = TimeGenerator.between(start, finish, :struct)

    Formatter.format_time(time, format)
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

  ## Options

  - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.morning()
      ~T[08:30:15]

      iex> NeoFaker.Time.morning(format: :iso8601)
      "09:45:22"

  """
  @spec morning(Keyword.t()) :: Time.t() | String.t()
  def morning(opts \\ []), do: between(~T[06:00:00], ~T[11:59:59], opts)

  @doc """
  Generates a random afternoon time (12:00–17:59).

  ## Options

  - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.afternoon()
      ~T[14:30:15]

      iex> NeoFaker.Time.afternoon(format: :iso8601)
      "15:45:22"

  """
  @spec afternoon(Keyword.t()) :: Time.t() | String.t()
  def afternoon(opts \\ []), do: between(~T[12:00:00], ~T[17:59:59], opts)

  @doc """
  Generates a random evening time (18:00–23:59).

  ## Options

  - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.evening()
      ~T[20:30:15]

      iex> NeoFaker.Time.evening(format: :iso8601)
      "21:45:22"

  """
  @spec evening(Keyword.t()) :: Time.t() | String.t()
  def evening(opts \\ []), do: between(~T[18:00:00], ~T[23:59:59], opts)

  @doc """
  Generates a random night time (00:00–05:59).

  ## Options

  - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.night()
      ~T[02:30:15]

      iex> NeoFaker.Time.night(format: :iso8601)
      "03:45:22"

  """
  @spec night(Keyword.t()) :: Time.t() | String.t()
  def night(opts \\ []), do: between(~T[00:00:00], ~T[05:59:59], opts)

  @doc """
  Returns the current UTC time.

  A convenience wrapper that returns `Time.utc_now()` with optional formatting.

  ## Options

  - `:format` - Output format. Either `:struct` (default) or `:iso8601`.

  ## Examples

      iex> NeoFaker.Time.now()
      ~T[15:22:10]

      iex> NeoFaker.Time.now(format: :iso8601)
      "15:22:10"

  """
  @spec now(Keyword.t()) :: Time.t() | String.t()
  def now(opts \\ []),
    do: Formatter.format_time(Time.utc_now(), TimeValidator.get_and_validate_format!(opts))
end
