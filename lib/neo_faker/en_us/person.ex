defmodule NeoFaker.EnUs.Person do
  @moduledoc """
  Provides functions for generating person-related information specific to the United States
  locale.

  This module offers a variety of functions to generate random personal details specific to the
  United States, such as Social Security Numbers (SSNs), among others.
  """

  alias NeoFaker.Number

  @doc """
  Generates a random SSN.

  Returns a random SSN (Social Security Number).

  ## Examples

      iex> NeoFaker.EnUs.Person.ssn()
      "184-63-2006"

  """
  def ssn do
    group_number = 1 |> Number.between(99) |> to_string() |> String.pad_leading(2, "0")
    serial_number = 1 |> Number.between(9999) |> to_string() |> String.pad_leading(4, "0")

    "#{area_number()}-#{group_number}-#{serial_number}"
  end

  # Generate a random area number, if the area number is 666 replace it with 777
  defp area_number do
    number = Number.between(1, 899)

    case number do
      666 -> "777"
      _ -> number |> to_string() |> String.pad_leading(3, "0")
    end
  end
end
