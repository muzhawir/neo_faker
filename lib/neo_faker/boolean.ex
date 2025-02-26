defmodule NeoFaker.Boolean do
  @moduledoc """
  Provides functions for generating boolean values.

  This module offers a function to generate random boolean values with a configurable probability.
  """
  @moduledoc since: "0.5.0"

  @doc """
  Returns a random boolean value.

  By default, the function returns `true` or `false` with equal probability (50% each).
  An optional `true_ratio` argument can be provided to adjust the chance of returning `true`.

  If the `integer: true` option is set to `true`, the function returns `1` for `true` or `0`
  for `false`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(75, integer: true)
      1

  """
  @spec boolean(pos_integer(), Keyword.t()) :: boolean()
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
