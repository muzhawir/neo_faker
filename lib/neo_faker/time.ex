defmodule NeoFaker.Time do
  @moduledoc """
  Functions for generating random times.

  This module provides utilities to generate random times, including times within a specific
  range, time zones, and more. All functions support both struct and ISO 8601 string formats.
  """
  @moduledoc since: "0.10.0"

  alias NeoFaker.Data.Generator
  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Time.Generator, as: TimeGenerator

  @midnight ~T[00:00:00]
  @end_of_day ~T[23:59:59]

  @doc """
  Generates a random time.

  Returns a time within the default range of 24 hours before and 24 hours after the current time.
  The range can be specified in hours, minutes, or seconds.

  ## Parameters

  - `range` - The range of time units relative to now. Defaults to `-24..24`.
  - `opts` - Keyword list of options:
    - `:unit` - Specifies the unit of time range. Defaults to `:hour`.
    - `:format` - Specifies the format of the time. Defaults to `:struct`.

  ## Options

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

      iex> NeoFaker.Time.add(-5..5, unit: :hour, format: :struct)
      ~T[12:30:45]

      iex> NeoFaker.Time.add(0..30, unit: :second)
      ~T[14:22:35]

  """
  @spec add(Range.t(), Keyword.t()) :: Time.t() | String.t()
  def add(range \\ Constants.default_time_range(), opts \\ []) do
    validate_range!(range)
    unit = get_and_validate_unit!(opts)
    format = get_and_validate_format!(opts)

    time = TimeGenerator.add(range, unit, :struct)
    Formatter.format_time(time, format)
  end

  @doc """
  Generates a random time between two times.

  Returns a random time between the specified start and finish times. Both times are inclusive.

  ## Parameters

  - `start` - The start time (inclusive). Defaults to `~T[00:00:00]`.
  - `finish` - The end time (inclusive). Defaults to `~T[23:59:59]`.
  - `opts` - Keyword list of options:
    - `:format` - Specifies the format of the time. Defaults to `:struct`.

  ## Options

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
  def between(start \\ @midnight, finish \\ @end_of_day, opts \\ []) do
    validate_time_order!(start, finish)
    format = get_and_validate_format!(opts)

    time = TimeGenerator.between(start, finish, :struct)

    Formatter.format_time(time, format)
  end

  @doc """
  Generates a random time zone.

  Returns a random time zone from a predefined list of time zones.

  ## Examples

      iex> NeoFaker.Time.time_zone()
      "Asia/Makassar"

      iex> NeoFaker.Time.time_zone()
      "America/New_York"

  """
  @spec time_zone() :: String.t()
  def time_zone do
    Generator.random_value(__MODULE__, Constants.time_zone_file(), "time_zone")
  end

  @doc """
  Generates a random morning time.

  Returns a time between 6:00 AM and 11:59 AM.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Time.morning()
      ~T[08:30:15]

      iex> NeoFaker.Time.morning(format: :iso8601)
      "09:45:22"

  """
  @spec morning(Keyword.t()) :: Time.t() | String.t()
  def morning(opts \\ []), do: between(~T[06:00:00], ~T[11:59:59], opts)

  @doc """
  Generates a random afternoon time.

  Returns a time between 12:00 PM and 5:59 PM.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Time.afternoon()
      ~T[14:30:15]

      iex> NeoFaker.Time.afternoon(format: :iso8601)
      "15:45:22"

  """
  @spec afternoon(Keyword.t()) :: Time.t() | String.t()
  def afternoon(opts \\ []), do: between(~T[12:00:00], ~T[17:59:59], opts)

  @doc """
  Generates a random evening time.

  Returns a time between 6:00 PM and 11:59 PM.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Time.evening()
      ~T[20:30:15]

      iex> NeoFaker.Time.evening(format: :iso8601)
      "21:45:22"

  """
  @spec evening(Keyword.t()) :: Time.t() | String.t()
  def evening(opts \\ []), do: between(~T[18:00:00], ~T[23:59:59], opts)

  @doc """
  Generates a random night time.

  Returns a time between 12:00 AM and 5:59 AM.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Time.night()
      ~T[02:30:15]

      iex> NeoFaker.Time.night(format: :iso8601)
      "03:45:22"

  """
  @spec night(Keyword.t()) :: Time.t() | String.t()
  def night(opts \\ []), do: between(~T[00:00:00], ~T[05:59:59], opts)

  @doc """
  Returns the current time.

  This is a convenience function that returns the current local time.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Time.now()
      ~T[15:22:10]

      iex> NeoFaker.Time.now(format: :iso8601)
      "15:22:10"

  """
  @spec now(Keyword.t()) :: Time.t() | String.t()
  def now(opts \\ []), do: Formatter.format_time(Time.utc_now(), get_and_validate_format!(opts))

  # Private functions

  @spec get_and_validate_format!(Keyword.t()) :: atom()
  defp get_and_validate_format!(opts) do
    format = Options.get(opts, :format, :struct)

    case Options.validate_enum(:format, format, Constants.valid_datetime_formats()) do
      :ok ->
        format

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec get_and_validate_unit!(Keyword.t()) :: atom()
  defp get_and_validate_unit!(opts) do
    unit = Options.get(opts, :unit, :hour)

    case Options.validate_enum(:unit, unit, Constants.valid_time_units()) do
      :ok ->
        unit

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_range!(Range.t()) :: :ok
  defp validate_range!(range) when is_struct(range, Range) do
    if range.first <= range.last do
      :ok
    else
      raise ArgumentError, "Invalid range: first must be less than or equal to last"
    end
  end

  defp validate_range!(invalid) do
    raise ArgumentError, "Expected a Range, got: #{inspect(invalid)}"
  end

  @spec validate_time_order!(Time.t(), Time.t()) :: :ok
  defp validate_time_order!(start, finish) do
    case Time.compare(start, finish) do
      :gt ->
        raise ArgumentError, "start time must be before or equal to finish time"

      _ ->
        :ok
    end
  end
end
