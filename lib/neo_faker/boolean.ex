defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating boolean values.

  This module provides utilities to generate random boolean values with configurable
  probabilities, allowing for controlled randomness.
  """
  @moduledoc since: "0.5.0"

  @doc """
  Generates a random boolean value with a configurable probability of returning `true`.

  By default, returns `true` or `false` with equal probability. The `true_ratio` parameter sets
  the percentage chance (0–100) of returning `true`. If the `integer: true` option is provided,
  returns `1` for `true` and `0` for `false`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(75, integer: true)
      1

  """
  @spec boolean(0..100, Keyword.t()) :: boolean() | non_neg_integer()
  def boolean(true_ratio \\ 50, opts \\ [])

  def boolean(true_ratio, opts) when true_ratio in 0..100 do
    result = :rand.uniform() <= true_ratio / 100

    if Keyword.get(opts, :integer, false) do
      if result, do: 1, else: 0
    else
      result
    end
  end

  def boolean(true_ratio, _opts) do
    raise ArgumentError, "true_ratio must be between 0 and 100, got: #{true_ratio}"
  end
end
