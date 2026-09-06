defmodule NeoFaker.Blood.Generator do
  @moduledoc false

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @doc """
  Generates a random ABO blood type.
  """
  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @doc """
  Generates a random Rh factor.
  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)

  @doc """
  Returns all 4 blood types in the ABO system.
  """
  @spec all_types() :: [String.t()]
  def all_types, do: @blood_types

  @doc """
  Returns both possible Rh factors.
  """
  @spec all_rh_factors() :: [String.t()]
  def all_rh_factors, do: @rh_factors
end
