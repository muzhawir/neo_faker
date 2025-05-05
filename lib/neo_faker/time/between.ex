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

  def random_between_time(start, finish, :struct) do
    {time_to_seconds_start, _microseconds} = Time.to_seconds_after_midnight(start)
    {time_to_seconds_finish, _microseconds} = Time.to_seconds_after_midnight(finish)

    {start_seconds, finish_seconds} =
      Enum.min_max([time_to_seconds_start, time_to_seconds_finish])

    amount_to_add = Enum.random(start_seconds..finish_seconds) - start_seconds

    Time.add(start, amount_to_add, :second)
  end

  def random_between_time(start, finish, :iso8601) do
    start |> random_between_time(finish, :struct) |> Time.to_iso8601()
  end
end
