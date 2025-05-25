defmodule NeoFaker.Time.Between do
  @moduledoc false

  @type time_format :: :struct | :iso8601
  @type time_unit :: :hour | :minute | :second

  @doc """
  Generates a random `Time` between two given `Time` values.

  Returns:
  - a `Time` struct when the format is `:struct`
  - a string in the format `"HH:MM:SS"` when the format is `:iso8601`
  """
  @spec random_between_time(Time.t(), Time.t(), time_format()) :: Time.t() | String.t()
  def random_between_time(start, finish, format) do
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
