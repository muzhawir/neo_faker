defmodule NeoFaker.Blood do
  @moduledoc """
  Functions for generating blood types.

  This module provides utilities to generate random blood groups, blood types, and Rh factors.
  """
  @moduledoc since: "0.3.1"

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @doc """
  Generates a random blood group.

  Returns a blood group, which consists of a blood type (`A`, `B`, `AB`, or `O`) combined with an
  Rh factor (`+` or `-`), forming a complete blood group.

  ## Examples

      iex> NeoFaker.Blood.group()
      "B+"

  """
  @spec group() :: String.t()
  def group, do: "#{type()}#{rh_factor()}"

  @doc """
  Generates a random blood type.

  Returns a string representing a blood type without the Rh factor.

  ## Examples

      iex> NeoFaker.Blood.type()
      "B"

  """
  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @doc """
  Generates a random Rh factor.

  Returns a string representing the Rh factor, which can be either `+` or `-`.

  ## Examples

      iex> NeoFaker.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)
end
