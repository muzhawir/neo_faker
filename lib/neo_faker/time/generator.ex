defmodule NeoFaker.Time.Generator do
  @moduledoc false

  @type unit :: :hour | :minute | :second

  @doc """
  Returns the current UTC time, truncated to seconds, shifted by a random number of
  `unit`s drawn from `range`. The result wraps around midnight.
  """
  @spec add(Range.t(), unit()) :: Time.t()
  def add(range, unit) do
    Time.utc_now()
    |> Time.truncate(:second)
    |> Time.add(Enum.random(range), unit)
  end

  @doc """
  Returns a random time between `start` and `finish`, inclusive.

  `start` must not be after `finish`. The draw is made in whole seconds when both
  bounds have second precision, which keeps the result at second precision too;
  otherwise it is made in microseconds, so a sub-second bound is never overshot.
  """
  @spec between(Time.t(), Time.t()) :: Time.t()
  def between(start, finish) do
    unit = if whole_second?(start) and whole_second?(finish), do: :second, else: :microsecond

    Time.add(start, Enum.random(0..Time.diff(finish, start, unit)), unit)
  end

  defp whole_second?(%Time{microsecond: {_value, precision}}), do: precision == 0
end
