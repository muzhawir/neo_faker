defmodule NeoFaker.Number.Generator do
  @moduledoc false

  @spec float_between(float(), float()) :: float()
  def float_between(min, max) when min == max, do: min

  def float_between(min, max) when is_float(min) and is_float(max) do
    :rand.uniform() * (max - min) + min
  end

  @spec to_float(number()) :: float()
  def to_float(n) when is_float(n), do: n
  def to_float(n) when is_integer(n), do: n + 0.0
end
