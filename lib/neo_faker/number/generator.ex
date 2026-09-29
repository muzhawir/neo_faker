defmodule NeoFaker.Number.Generator do
  @moduledoc false

  @doc """
  Returns a uniformly distributed float between `min` and `max`.

  Interpolates as `min * (1 - u) + max * u` rather than `min + u * (max - min)`,
  because `max - min` overflows for bounds near the largest float (for example
  `-1.0e308` and `1.0e308`), which raises `ArithmeticError`.
  """
  @spec float_between(float(), float()) :: float()
  def float_between(min, max) when min == max, do: min

  def float_between(min, max) do
    u = :rand.uniform()
    min * (1 - u) + max * u
  end

  @doc """
  Converts an integer to a float; floats are returned unchanged.
  """
  @spec to_float(number()) :: float()
  def to_float(n) when is_float(n), do: n
  def to_float(n) when is_integer(n), do: n * 1.0
end
