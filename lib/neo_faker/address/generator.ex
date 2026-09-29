defmodule NeoFaker.Address.Generator do
  @moduledoc false

  @doc """
  Returns a uniformly distributed latitude in `-90.0..90.0`, rounded to `precision`.
  """
  @spec latitude(0..15) :: float()
  def latitude(precision), do: coordinate(90, precision)

  @doc """
  Returns a uniformly distributed longitude in `-180.0..180.0`, rounded to `precision`.
  """
  @spec longitude(0..15) :: float()
  def longitude(precision), do: coordinate(180, precision)

  defp coordinate(bound, precision) do
    Float.round(:rand.uniform() * 2 * bound - bound, precision)
  end
end
