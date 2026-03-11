defmodule NeoFaker.Address.Generator do
  @moduledoc false

  @doc """
  Generates a random latitude value rounded to the given precision.

  Returns a float between -90.0 and 90.0.
  """
  @spec latitude(non_neg_integer()) :: float()
  def latitude(precision), do: Float.round(:rand.uniform() * 180 - 90, precision)

  @doc """
  Generates a random longitude value rounded to the given precision.

  Returns a float between -180.0 and 180.0.
  """
  @spec longitude(non_neg_integer()) :: float()
  def longitude(precision), do: Float.round(:rand.uniform() * 360 - 180, precision)
end
