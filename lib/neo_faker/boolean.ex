defmodule NeoFaker.Boolean do
  @moduledoc """
  Provides functions for generating boolean values.

  This module offers a function to generate random boolean values with a configurable probability.
  """
  @moduledoc since: "0.5.0"

  @doc """
  Returns a random boolean value.

  By default, the function returns `true` or `false` with equal probability (50% each).
  An optional argument can be provided to adjust the chance of returning `true`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

  """
  @spec boolean(pos_integer()) :: boolean()
  def boolean(true_ratio \\ 50) when true_ratio in 0..100 do
    :rand.uniform() <= true_ratio / 100
  end
end
