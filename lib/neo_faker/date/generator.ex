defmodule NeoFaker.Date.Generator do
  @moduledoc false

  @doc """
  Generates a random date offset from today by a day count drawn from `range`.

  `range` may include negative values (past), positive values (future), or straddle zero; the
  offset is added to today's local date via `Date.add/2`, which handles either direction the same
  way.
  """
  @spec add(Range.t()) :: Date.t()
  def add(range) do
    NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.add(Enum.random(range))
  end

  @doc """
  Generates a random date between two dates, inclusive.
  """
  @spec between(Date.t(), Date.t()) :: Date.t()
  def between(start, finish) do
    start |> Date.range(finish) |> Enum.random()
  end

  @doc """
  Returns the current local date as a `Date` struct.
  """
  @spec local_date_now() :: Date.t()
  def local_date_now, do: NaiveDateTime.to_date(NaiveDateTime.local_now())
end
