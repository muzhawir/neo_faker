defmodule NeoFaker.Date.Utils do
  @moduledoc false

  @type format :: :date | :iso8601

  @doc """
  Generate a random date with sepecified range.
  """
  @spec random_add_date(Range.t(), format()) :: Date.t() | String.t()
  def random_add_date(range, :sigil), do: Date.add(NaiveDateTime.local_now(), Enum.random(range))

  def random_add_date(range, :iso8601) do
    NaiveDateTime.local_now() |> Date.add(Enum.random(range)) |> Date.to_iso8601()
  end

  @doc """
  Generate a random date with a specific between two dates.
  """
  @spec random_between_date(Date.t(), Date.t(), format()) :: Date.t() | String.t()
  def random_between_date(start, finish, :sigil), do: start |> Date.range(finish) |> Enum.random()

  def random_between_date(start, finish, :iso8601) do
    start |> Date.range(finish) |> Enum.random() |> Date.to_iso8601()
  end
end
