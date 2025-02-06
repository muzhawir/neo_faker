defmodule NF.Blood do
  @moduledoc """
  Functions for generate random blood type.
  """

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @doc """
  Generate a random blood group name.

  Returns a blood type in full format like `A-` or `B+`.

  ## Examples

      iex> NF.Blood.group()
      "B+"

  """
  @spec group() :: String.t()
  def group, do: "#{type()}#{rh_factor()}"

  @doc """
  Generate a random blood type.

  Returns a blood type like `A` or `B`.

  ## Examples

      iex> NF.Blood.type()
      "B"

  """
  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @doc """
  Generate arandom rh factor.

  Returns a random rh factor like `+` or `-`.

  ## Examples

      iex> NF.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)
end
