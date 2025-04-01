defmodule NeoFaker.Date.Utils do
  @moduledoc false

  @type format :: :date | :iso8601

  @doc """
  Generate a random date with sepecified range.
  """
  @spec random_add_date(Range.t(), format()) :: Date.t() | String.t()
  def random_add_date(range, :date), do: Date.add(Date.utc_today(), Enum.random(range))

  def random_add_date(range, :iso8601) do
    Date.utc_today() |> Date.add(Enum.random(range)) |> Date.to_iso8601()
  end

  @doc """
  Generate a random date with a specific between two dates.
  """
  @spec random_between_date(Date.t(), Date.t(), format()) :: Date.t() | String.t()
  def random_between_date(start, finish, :date), do: start |> Date.range(finish) |> Enum.random()

  def random_between_date(start, finish, :iso8601) do
    start |> Date.range(finish) |> Enum.random() |> Date.to_iso8601()
  end
end
