defmodule Nf.Boolean do
  @moduledoc """
  Functions for generating boolean values.
  """
  @moduledoc since: "0.5.0"

  @doc """
  Generate a boolean value.

  Returns a boolean value, default true ratio is 50% if no argument is provided.

  ## Examples

      iex> Nf.Boolean.boolean()
      true

      iex> Nf.Boolean.boolean(50)
      false

  """
  @spec boolean(pos_integer()) :: boolean()
  def boolean(true_ratio \\ 50) when true_ratio in 0..100 do
    :rand.uniform() <= true_ratio / 100
  end
end
