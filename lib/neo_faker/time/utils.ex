defmodule NeoFaker.Time.Utils do
  @moduledoc false

  @type time_format :: :sigil | :iso8601
  @type time_unit :: :hour | :minute | :second

  @doc """
  Generate a random time with sepecified day range.
  """
  @spec random_add_time(Range.t(), time_unit(), time_format()) :: Time.t() | String.t()
  def random_add_time(range, unit, :sigil) do
    NaiveDateTime.local_now() |> Time.add(Enum.random(range), unit) |> Time.truncate(:second)
  end

  def random_add_time(range, unit, :iso8601) do
    range |> random_add_time(unit, :sigil) |> Time.to_iso8601()
  end

  @doc """
  Generate a random time with a specific between two times.
  """
  @spec random_between_time(Time.t(), Time.t(), time_format()) :: Time.t() | String.t()
  def random_between_time(start, finish, :sigil) do
    {time_to_seconds_start, _microseconds} = Time.to_seconds_after_midnight(start)
    {time_to_seconds_finish, _microseconds} = Time.to_seconds_after_midnight(finish)

    {start_seconds, finish_seconds} =
      Enum.min_max([time_to_seconds_start, time_to_seconds_finish])

    seconds = Enum.random(start_seconds..finish_seconds) - start_seconds

    Time.add(start, seconds, :second)
  end

  def random_between_time(start, finish, :iso8601) do
    start |> random_between_time(finish, :sigil) |> Time.to_iso8601()
  end
end
