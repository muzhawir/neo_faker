defmodule NeoFaker.Time.Add do
  @moduledoc false

  @type time_format :: :sigil | :iso8601
  @type time_unit :: :hour | :minute | :second

  
  
  @doc """
  Generates a random time by adding a random value from the given range to the current local time in the specified unit.
  
  Returns the resulting time as a `Time` struct when the format is `:sigil`, or as an ISO 8601 string when the format is `:iso8601`.
  """
  def random_add_time(range, unit, :sigil) do
    NaiveDateTime.local_now() |> Time.add(Enum.random(range), unit) |> Time.truncate(:second)
  end

  @doc """
  Returns the current local time with a random amount added in the specified unit, formatted as an ISO 8601 string.
  
  The random amount is selected from the given range and added to the current time in the specified unit (`:hour`, `:minute`, or `:second`). The result is returned as an ISO 8601 formatted string.
  """
  def random_add_time(range, unit, :iso8601) do
    range |> random_add_time(unit, :sigil) |> Time.to_iso8601()
  end
end
