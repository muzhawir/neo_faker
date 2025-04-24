defmodule NeoFaker.EnUs.Person do
  @moduledoc """
  Functions for generating person-related information specific to the United States.

  This module provides utilities to generate random personal details specific to the United States,
  such as Social Security Numbers (SSNs).
  """
  @moduledoc since: "0.9.0"

  import NeoFaker.EnUs.Person.Utils

  @doc """
  Generates a random SSN.

  Returns a random SSN (Social Security Number).

  ## Examples

      iex> NeoFaker.EnUs.Person.ssn()
      "184-63-2006"

  """
  @spec ssn() :: String.t()
  def ssn, do: "#{area_number()}-#{serial_number(99, 2)}-#{serial_number(9999, 4)}"
end
