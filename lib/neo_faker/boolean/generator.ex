defmodule NeoFaker.Boolean.Generator do
  @moduledoc false

  @spec boolean(0..100) :: boolean()
  def boolean(true_ratio), do: :rand.uniform() <= true_ratio / 100
end
