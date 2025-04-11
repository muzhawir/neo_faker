defmodule NeoFaker.EnUs.Person do
  @moduledoc """
  Functions for generating person-related information specific to the United States.

  This module provides utilities to generate random personal details specific to the United States,
  such as Social Security Numbers (SSNs).
  """
  @moduledoc since: "0.9.0"

  import NeoFaker.EnUs.Person.Utils

  alias NeoFaker.Number

  @doc """
  Generates a random SSN.

  Returns a random SSN (Social Security Number).

  ## Examples

      iex> NeoFaker.EnUs.Person.ssn()
      "184-63-2006"

  """
  @spec ssn() :: String.t()
  def ssn do
    group_number = 1 |> Number.between(99) |> to_string() |> String.pad_leading(2, "0")
    serial_number = 1 |> Number.between(9999) |> to_string() |> String.pad_leading(4, "0")

    "#{area_number()}-#{group_number}-#{serial_number}"
  end
end
