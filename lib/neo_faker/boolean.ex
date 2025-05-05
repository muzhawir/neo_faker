defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating boolean values.

  This module provides utilities to generate random boolean values with configurable
  probabilities, allowing for controlled randomness.
  """
  @moduledoc since: "0.5.0"

  
  
  @doc """
Generates a random boolean value with a configurable probability of returning `true`.

By default, returns `true` or `false` with equal probability. The `true_ratio` parameter sets the percentage chance (0–100) of returning `true`. If the `integer: true` option is provided, returns `1` for `true` and `0` for `false`.

## Examples

    iex> NeoFaker.Boolean.boolean()
    false

    iex> NeoFaker.Boolean.boolean(75)
    true

    iex> NeoFaker.Boolean.boolean(75, integer: true)
    1

"""
def boolean(true_ratio \\ 50, opts \\ [])

  @doc """
  Returns a random boolean value, with the probability of `true` determined by `true_ratio`.
  
  The result is `true` with probability equal to `true_ratio` percent (from 0 to 100), and `false` otherwise.
  """
  def boolean(true_ratio, []) when true_ratio in 0..100 do
    :rand.uniform() <= true_ratio / 100
  end

  @doc """
Returns a random boolean value with a probability of `true` determined by `true_ratio`.

This clause is used when the `integer: false` option is specified, and is equivalent to calling `boolean/0`.
"""
def boolean(true_ratio, integer: false) when true_ratio in 0..100, do: boolean()

  @doc """
  Returns `1` with probability equal to `true_ratio` percent, or `0` otherwise.
  
  This function generates a random boolean outcome based on the specified probability, returning the result as an integer (`1` for `true`, `0` for `false`).
  """
  def boolean(true_ratio, integer: true) when true_ratio in 0..100 do
    result = :rand.uniform() <= true_ratio / 100

    if result == true, do: 1, else: 0
  end
end
