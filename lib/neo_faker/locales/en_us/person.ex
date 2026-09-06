defmodule NeoFaker.Locales.EnUs.Person do
  @moduledoc """
  Functions for generating person-related information specific to the United States.

  Provides utilities to generate random personal details specific to the United States, such
  as Social Security Numbers (SSNs).
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Locales.EnUs.Person.Generator

  @doc """
  Generates a random SSN.

  Returns a random SSN (Social Security Number).

  ## Examples

      iex> NeoFaker.Locales.EnUs.Person.ssn()
      "184-63-2006"

  """
  @spec ssn() :: String.t()
  def ssn,
    do:
      "#{Generator.area_number()}-#{Generator.serial_number(99, 2)}-#{Generator.serial_number(9999, 4)}"
end
