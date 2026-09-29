defmodule NeoFaker.Date.Generator do
  @moduledoc false

  @doc """
  Returns today's local date shifted by a random number of days drawn from `range`.
  """
  @spec add(Range.t()) :: Date.t()
  def add(range), do: Date.add(local_date_now(), Enum.random(range))

  @doc """
  Returns a random date between `start` and `finish`, inclusive.

  `Date.Range` implements `Enumerable.count/1` and `slice/1`, so `Enum.random/1`
  picks a day in constant time without walking the range.
  """
  @spec between(Date.t(), Date.t()) :: Date.t()
  def between(start, finish), do: start |> Date.range(finish) |> Enum.random()

  @doc """
  Returns the current date in the local time zone of the host.
  """
  @spec local_date_now() :: Date.t()
  def local_date_now, do: NaiveDateTime.to_date(NaiveDateTime.local_now())
end
