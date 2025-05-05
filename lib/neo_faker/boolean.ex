defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating boolean values.

  This module provides utilities to generate random boolean values with configurable
  probabilities, allowing for controlled randomness.
  """
  @moduledoc since: "0.5.0"

  @doc """
  Generates a random boolean value.

  By default, this function returns `true` or `false` with equal probability (50% each).
  An optional `true_ratio` argument can be provided to adjust the probability of returning `true`.

  If the `integer: true` option is set, the function returns `1` for `true` and `0` for `false`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(75, integer: true)
      1

  """
  @spec boolean(1..100, Keyword.t()) :: boolean() | non_neg_integer()
  def boolean(true_ratio \\ 50, opts \\ [])

  def boolean(true_ratio, []) when true_ratio in 0..100 do
    :rand.uniform() <= true_ratio / 100
  end

  def boolean(true_ratio, integer: false) when true_ratio in 0..100, do: boolean()

  def boolean(true_ratio, integer: true) when true_ratio in 0..100 do
    result = :rand.uniform() <= true_ratio / 100

    if result == true, do: 1, else: 0
  end

  def boolean(true_ratio, _opts) when not (true_ratio in 0..100) do
    raise ArgumentError, "true_ratio must be between 0 and 100, got: #{true_ratio}"
  end
end
