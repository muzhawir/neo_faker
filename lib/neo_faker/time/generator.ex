defmodule NeoFaker.Time.Generator do
  @moduledoc false

  @type time_unit :: :hour | :minute | :second

  @doc """
  Generates a random time by adding a random value from the given range to the current local
  time in the specified unit.
  """
  @spec add(Range.t(), time_unit()) :: Time.t()
  def add(range, unit) do
    NaiveDateTime.local_now()
    |> Time.add(Enum.random(range), unit)
    |> Time.truncate(:second)
  end

  @doc """
  Generates a random `Time` between two given `Time` values.

  Requires `start` to already be chronologically at or before `finish`; every
  caller (`NeoFaker.Time.between/2`, and the morning/afternoon/evening/night
  helpers that go through it) enforces this first via
  `NeoFaker.Time.Validator.validate_time_order!/2`, so it isn't re-checked
  here. `Enum.min_max/1` below only picks out the smaller second-count to size
  the random offset; the offset is still added to the literal `start`
  argument, not to whichever value the seconds comparison found smaller, so
  this function must not be called directly with `start > finish`.
  """
  @spec between(Time.t(), Time.t()) :: Time.t()
  def between(start, finish) do
    {start_seconds, _} = Time.to_seconds_after_midnight(start)
    {finish_seconds, _} = Time.to_seconds_after_midnight(finish)
    {min_sec, max_sec} = Enum.min_max([start_seconds, finish_seconds])
    amount_to_add = Enum.random(min_sec..max_sec) - min_sec

    Time.add(start, amount_to_add, :second)
  end
end
