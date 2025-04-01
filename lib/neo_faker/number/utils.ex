defmodule NeoFaker.Number.Utils do
  @moduledoc false

  @doc """
  Generates a random number between `min` and `max`.

  This function delegates the call to `NeoFaker.Number.between/2`.
  """
  @spec between(number(), number()) :: number()
  def between(min \\ 0, max \\ 100)
  def between(min, max) when is_integer(min) and is_integer(max), do: Enum.random(min..max)

  def between(min, max) when is_float(min) and is_float(max) do
    :rand.uniform() * (max - min) + min
  end
end
