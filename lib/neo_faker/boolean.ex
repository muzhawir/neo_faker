defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating boolean values.

  This module provides utilities to generate random boolean values with configurable
  probabilities, allowing for controlled randomness.
  """
  @moduledoc since: "0.5.0"

  alias NeoFaker.Boolean.Utils

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
  @spec boolean(pos_integer(), Keyword.t()) :: boolean() | non_neg_integer()
  defdelegate boolean(true_ratio \\ 50, opts \\ []), to: Utils, as: :boolean
end
