defmodule NeoFaker.Boolean.Generator do
  @moduledoc false

  @doc """
  Returns `true` with a probability of `true_ratio / 100`.

  Draws an integer from `1..100` rather than comparing a float with `<=`:
  `:rand.uniform/0` can return exactly `0.0`, which would make a ratio of `0`
  occasionally return `true`.
  """
  @spec boolean(0..100) :: boolean()
  def boolean(true_ratio), do: :rand.uniform(100) <= true_ratio
end
