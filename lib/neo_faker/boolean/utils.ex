defmodule NeoFaker.Boolean.Utils do
  @moduledoc false

  @doc """
  Generates a random boolean value.

  This function delegates the call to `NeoFaker.Boolean.boolean/2`.
  """
  @spec boolean(number(), Keyword.t()) :: boolean() | non_neg_integer()
  def boolean(true_ratio \\ 50, opts \\ [])

  def boolean(true_ratio, []) when true_ratio in 0..100 do
    :rand.uniform() <= true_ratio / 100
  end

  def boolean(true_ratio, integer: false) when true_ratio in 0..100, do: boolean()

  def boolean(true_ratio, integer: true) when true_ratio in 0..100 do
    result = :rand.uniform() <= true_ratio / 100

    if result == true, do: 1, else: 0
  end
end
