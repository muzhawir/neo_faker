defmodule NeoFaker.Time.Add do
  @moduledoc false

  @type time_format :: :struct | :iso8601
  @type time_unit :: :hour | :minute | :second

  @doc """
  Generates a random time by adding a random value from the given range to the current local
  in the specified unit.

  Returns the resulting time as a `Time` struct when the format is `:struct`, or as an ISO 8601
  string when the format is `:iso8601`.
  """
  @spec random_add_time(Range.t(), time_unit(), time_format()) :: Time.t() | String.t()
  def random_add_time(range, unit, :struct) do
    NaiveDateTime.local_now() |> Time.add(Enum.random(range), unit) |> Time.truncate(:second)
  end

  def random_add_time(range, unit, :iso8601) do
    range |> random_add_time(unit, :struct) |> Time.to_iso8601()
  end
end
