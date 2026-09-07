defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating random boolean values.

  Provides a single function to generate `true` or `false` with a configurable probability.
  """
  @moduledoc since: "0.5.0"

  alias NeoFaker.Boolean.Generator

  @ratio_range 0..100

  @doc """
  Generates a random boolean value with a configurable probability of returning `true`.

  The `true_ratio` parameter sets the percentage chance (0–100) of returning `true`.
  Defaults to `50`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(0)
      false

      iex> NeoFaker.Boolean.boolean(100)
      true

  """
  @spec boolean(0..100) :: boolean()
  def boolean(true_ratio \\ 50)

  def boolean(true_ratio) when true_ratio in @ratio_range do
    Generator.boolean(true_ratio)
  end

  def boolean(true_ratio) do
    raise ArgumentError, "true_ratio must be between 0 and 100, got: #{true_ratio}"
  end
end
