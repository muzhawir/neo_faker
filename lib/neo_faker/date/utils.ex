defmodule NeoFaker.Date.Utils do
  @moduledoc false

  # Generate a random date with specified format.
  def random_date(range, :date), do: Date.add(Date.utc_today(), Enum.random(range))

  def random_date(range, :iso8601) do
    Date.utc_today() |> Date.add(Enum.random(range)) |> Date.to_iso8601()
  end
end
