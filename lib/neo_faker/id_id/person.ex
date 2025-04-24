defmodule NeoFaker.IdId.Person do
  @moduledoc """
  Functions for generating person-related information specific to Indonesia.

  This module provides utilities to generate random personal details specific to Indonesia, such
  as Nomor Induk Kependudukan (NIK).
  """
  @moduledoc since: "0.9.0"

  import NeoFaker.IdId.Person.Utils

  alias NeoFaker.Number

  @doc """
  Generates a random NIK.

  Returns a random NIK (Nomor Induk Kependudukan).

  ## Examples

      iex> NeoFaker.IdId.Person.nik()
      "7645504903500640"

  """
  @spec nik() :: String.t()
  def nik do
    province_number = Number.between(11, 92)
    regency_number = serial_number(79, 2)
    district_number = serial_number(53, 2)
    serial_number = serial_number(9999, 4)

    "#{province_number}#{regency_number}#{district_number}#{birth_date()}#{serial_number}"
  end
end
