defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating boolean values.

  This module provides utilities to generate random boolean values with configurable
  probabilities, allowing for controlled randomness.
  """
  @moduledoc since: "0.5.0"

  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options

  @valid_ratio_range 0..100

  @doc """
  Generates a random boolean value with a configurable probability of returning `true`.

  By default, returns `true` or `false` with equal probability. The `true_ratio` parameter sets
  the percentage chance (0–100) of returning `true`. If the `integer: true` option is provided,
  returns `1` for `true` and `0` for `false`.

  ## Parameters

  - `true_ratio` - The percentage probability (0-100) of returning `true`. Defaults to `50`.
  - `opts` - Keyword list of options:
    - `:integer` - When `true`, returns `1` or `0` instead of `true` or `false`. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(75, integer: true)
      1

      iex> NeoFaker.Boolean.boolean(0)
      false

      iex> NeoFaker.Boolean.boolean(100)
      true

  """
  @spec boolean(0..100, Keyword.t()) :: boolean() | non_neg_integer()
  def boolean(true_ratio \\ 50, opts \\ [])

  def boolean(true_ratio, opts) when true_ratio in @valid_ratio_range do
    result = generate_boolean(true_ratio)

    if Options.get(opts, :integer, false) do
      Formatter.format_boolean(result, :integer)
    else
      result
    end
  end

  def boolean(true_ratio, _opts) do
    raise ArgumentError, "true_ratio must be between 0 and 100, got: #{true_ratio}"
  end

  # Private functions

  @spec generate_boolean(0..100) :: boolean()
  defp generate_boolean(true_ratio), do: :rand.uniform() <= true_ratio / 100
end
