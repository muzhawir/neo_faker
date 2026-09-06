defmodule NeoFaker.Blood.Generator do
  @moduledoc false

  # Source lists for Blood.type/0 and Blood.rh_factor/0. all_types/0 and
  # all_rh_factors/0 return these verbatim, so this order is the documented
  # public return value, not just an internal detail; keep it ["A", "B", "AB",
  # "O"] / ["+", "-"] if either list ever needs to change.
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
