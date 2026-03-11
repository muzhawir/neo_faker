defmodule NeoFaker.Address.Generator do
  @moduledoc false

  @spec latitude(non_neg_integer()) :: float()
  def latitude(precision), do: Float.round(:rand.uniform() * 180 - 90, precision)

  @spec longitude(non_neg_integer()) :: float()
  def longitude(precision), do: Float.round(:rand.uniform() * 360 - 180, precision)
end
