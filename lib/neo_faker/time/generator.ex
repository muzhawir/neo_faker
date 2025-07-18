defmodule NeoFaker.Time.Generator do
  @moduledoc false

  @type time_format :: :struct | :iso8601
  @type time_unit :: :hour | :minute | :second

  @doc """
  Generates a random time by adding a random value from the given range to the current local
  time in the specified unit.

  Returns the resulting time as a `Time` struct when the format is `:struct`, or as an ISO 8601
  string when the format is `:iso8601`.
  """
  @spec add(Range.t(), time_unit(), time_format()) :: Time.t() | String.t()
  def add(range, unit, format) do
    time =
      NaiveDateTime.local_now()
      |> Time.add(Enum.random(range), unit)
      |> Time.truncate(:second)

    case format do
      :struct -> time
      :iso8601 -> Time.to_iso8601(time)
    end
  end

  @doc """
  Generates a random `Time` between two given `Time` values.

  Returns:
  - a `Time` struct when the format is `:struct`
  - a string in the format `"HH:MM:SS"` when the format is `:iso8601`
  """
  @spec between(Time.t(), Time.t(), time_format()) :: Time.t() | String.t()
  def between(start, finish, format) do
    {start_seconds, _} = Time.to_seconds_after_midnight(start)
    {finish_seconds, _} = Time.to_seconds_after_midnight(finish)
    {min_sec, max_sec} = Enum.min_max([start_seconds, finish_seconds])
    amount_to_add = Enum.random(min_sec..max_sec) - min_sec
    time = Time.add(start, amount_to_add, :second)

    case format do
      :struct -> time
      :iso8601 -> Time.to_iso8601(time)
    end
  end
end
