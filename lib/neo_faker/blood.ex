defmodule NeoFaker.Blood do
  @moduledoc """
  Provides functions for generating blood types.

  This module includes functions to generate random blood type groups, blood types, and Rh factors.
  """
  @moduledoc since: "0.3.1"

  @blood_types ~w[A B AB O]

  @doc """
  Returns a random blood type group.

  A blood type group consists of a blood type (`A`, `B`, `AB`, or `O`)
  and an Rh factor (`+` or `-`), forming a complete blood group.

  ## Examples

      iex> NeoFaker.Blood.group()
      "B+"

  """
  @spec group() :: String.t()
  def group, do: "#{type()}#{rh_factor()}"

  @doc """
  Returns a random blood type.

  A blood type is one of `A`, `B`, `AB`, or `O`, without the Rh factor.

  ## Examples

      iex> NeoFaker.Blood.type()
      "B"

  """
  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @doc """
  Returns a random Rh factor.

  The Rh factor is either `+` (positive) or `-` (negative).

  ## Examples

      iex> NeoFaker.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(["+", "-"])
end
