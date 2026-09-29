defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating random booleans.
  """
  @moduledoc since: "0.5.0"

  alias NeoFaker.Boolean.Generator

  @doc """
  Generates a random boolean.

  `true_ratio` is the chance, as an integer percentage from `0` to `100`, that the
  result is `true`. It defaults to `50`. A ratio of `0` always returns `false` and a
  ratio of `100` always returns `true`.

  Raises `ArgumentError` if `true_ratio` is not an integer from `0` to `100`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(0)
      false

  """
  @spec boolean(0..100) :: boolean()
  def boolean(true_ratio \\ 50)

  def boolean(true_ratio) when true_ratio in 0..100, do: Generator.boolean(true_ratio)

  def boolean(true_ratio) do
    raise ArgumentError,
          "true_ratio must be an integer between 0 and 100, got: #{inspect(true_ratio)}"
  end
end
