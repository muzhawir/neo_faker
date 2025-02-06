defmodule NeoFaker.Blood do
  @moduledoc """
  Functions for generate random blood type.
  """

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @doc """
  Generate random blood type in full format.

  Returns random blood type in full format like `B+`.

  ## Examples

      iex> NeoFaker.Blood.full_format()
      "B"

  """
  @spec full_format() :: String.t()
  def full_format, do: "#{blood_type()}#{rh_factor()}"

  @doc """
  Generate random blood type.

  Returns only the blood type like `A` or `AB`.

  ## Examples

      iex> NeoFaker.Blood.blood_type()
      "B+"

  """
  @spec blood_type() :: String.t()
  def blood_type, do: Enum.random(@blood_types)

  @doc """
  Generate random rh factor.

  Returns only random rh factor like `+` or `-`.

  ## Examples

      iex> NeoFaker.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)
end
