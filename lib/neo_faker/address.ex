defmodule NeoFaker.Address do
  @moduledoc """
  Functions for generating address-related data.

  This module provides utilities to generate random addresses, including street names, city names,
  country names, etc.
  """
  @moduledoc since: "0.12.0"

  import NeoFaker.Data.Generator, only: [random_value: 3, random_value: 4]

  alias NeoFaker.Number

  @doc """
  Generates a random building number within a specified range.

  Returns an integer or a string representation of the building number.

  ## Options

  - `:type` - Specifies the type of the building number to return.

  The values for `:type` can be:

  - `:string` - Returns the building number as a string (default).
  - `:integer` - Returns the building number as an integer.

  ## Examples

      iex> NeoFaker.Address.building_number(1..100)
      "25"

      iex> NeoFaker.Address.building_number(1..100, type: :integer)
      25

  """
  @spec building_number(Range.t(), keyword()) :: integer() | String.t()
  def building_number(range \\ 1..100, opts \\ []) do
    type = Keyword.get(opts, :type, :string)

    case type do
      :string ->
        range.first |> Number.between(range.last) |> Integer.to_string()

      _ ->
        Number.between(range.first, range.last)
    end
  end
end
