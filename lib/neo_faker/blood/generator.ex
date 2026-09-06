defmodule NeoFaker.Blood.Generator do
  @moduledoc false

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)

  @spec all_types() :: [String.t()]
  def all_types, do: @blood_types

  @spec all_rh_factors() :: [String.t()]
  def all_rh_factors, do: @rh_factors
end
