defmodule NeoFaker.Boolean.Generator do
  @moduledoc false

  @doc """
  Generates a random boolean value based on the given true ratio.

  Returns `true` with a probability of `true_ratio / 100`, and `false` otherwise.
  """
  @spec boolean(0..100) :: boolean()
  def boolean(true_ratio), do: :rand.uniform() <= true_ratio / 100
end
