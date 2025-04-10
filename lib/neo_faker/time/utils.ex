defmodule NeoFaker.Time.Utils do
  @moduledoc false

  @doc """
  Generate a random time with sepecified range.
  """
  def random_add_time(range, unit, :time) do
    Time.utc_now() |> Time.add(Enum.random(range), unit) |> Time.truncate(:second)
  end

  def random_add_time(range, unit, :iso8601) do
    Time.utc_now()
    |> Time.add(Enum.random(range), unit)
    |> Time.truncate(:second)
    |> Time.to_iso8601()
  end
end
