defmodule NeoFaker.Time.Add do
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
end
