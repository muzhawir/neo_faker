defmodule NeoFaker.Number.Generator do
  @moduledoc false

  @doc """
  Generates a random float between `min` and `max`.

  If `min` equals `max`, returns `min` as-is. Otherwise returns a uniformly distributed
  random float in the range `[min, max)`.
  """
  @spec float_between(float(), float()) :: float()
  def float_between(min, max) when min == max, do: min

  def float_between(min, max) when is_float(min) and is_float(max) do
    :rand.uniform() * (max - min) + min
  end

  @doc """
  Converts a number to a float.

  Returns the value unchanged if it is already a float, or adds `0.0` to coerce an integer
  into a float.
  """
  @spec to_float(number()) :: float()
  def to_float(n) when is_float(n), do: n
  def to_float(n) when is_integer(n), do: n + 0.0
end
