defmodule Nf.Blood do
  @moduledoc """
  Functions for generating a random blood type.
  """
  @moduledoc since: "0.3.1"

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @doc """
  Generate a random blood type group name.

  Returns a blood type in full format like `A-` or `B+`.

  ## Examples

      iex> Nf.Blood.group()
      "B+"

  """
  @spec group() :: String.t()
  def group, do: "#{type()}#{rh_factor()}"

  @doc """
  Generate a random blood type.

  Returns a blood type like `A` or `B`.

  ## Examples

      iex> Nf.Blood.type()
      "B"

  """
  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @doc """
  Generate arandom rh factor.

  Returns a random rh factor like `+` or `-`.

  ## Examples

      iex> Nf.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)
end
