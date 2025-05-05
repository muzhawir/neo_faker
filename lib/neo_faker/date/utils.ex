defmodule NeoFaker.Date.Utils do
  @moduledoc false

  @typedoc "Date format either sigil `~D` or iso8601 `YYYY-MM-DD`"
  @type date_format :: :sigil | :iso8601

  @doc """
  Generate a random date with sepecified range.

  Returns a random date as a `Date` struct when the format is `:sigil` or a string in the format
  `YYYY-MM-DD` when the format is `:iso8601`.
  """
  @spec random_add_date(Range.t(), date_format()) :: Date.t() | String.t()
  def random_add_date(range, :sigil), do: Date.add(NaiveDateTime.local_now(), Enum.random(range))

  def random_add_date(range, :iso8601) do
    NaiveDateTime.local_now() |> Date.add(Enum.random(range)) |> Date.to_iso8601()
  end

  @doc """
  Generate a random date with a specific between two dates.

  Returns a random date between `start` and `finish` as a `Date` struct when the format is
  `:sigil` or a string in the format `YYYY-MM-DD` when the format is `:iso8601`.
  """
  @spec random_between_date(Date.t(), Date.t(), date_format()) :: Date.t() | String.t()
  def random_between_date(start, finish, :sigil), do: start |> Date.range(finish) |> Enum.random()

  def random_between_date(start, finish, :iso8601) do
    start |> Date.range(finish) |> Enum.random() |> Date.to_iso8601()
  end

  @doc """
  Returns the current local date as a `Date` struct.
  """
  def local_date_now, do: NaiveDateTime.to_date(NaiveDateTime.local_now())
end
