defmodule NeoFaker.Locales.IdId.Person do
  @moduledoc """
  Functions for generating person-related information specific to Indonesia.

  This module provides utilities to generate random personal details specific to Indonesia, such
  as Nomor Induk Kependudukan (NIK).
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Locales.IdId.Person.Generator
  alias NeoFaker.Number

  @doc """
  Generates a random NIK.

  Returns a random NIK (Nomor Induk Kependudukan).

  ## Examples

      iex> NeoFaker.Locales.IdId.Person.nik()
      "7645504903500640"

  """
  @spec nik() :: String.t()
  def nik do
    province_number = Number.between(11, 92)
    regency_number = Generator.serial_number(79, 2)
    district_number = Generator.serial_number(53, 2)
    serial_number = Generator.serial_number(9999, 4)

    "#{province_number}#{regency_number}#{district_number}#{Generator.birth_date()}#{serial_number}"
  end

  @doc """
  Generates a random NPWP.

  Returns a random NPWP (Nomor Pokok Wajib Pajak), the tax identification number defined by
  UU No. 7 Tahun 2021 tentang Harmonisasi Peraturan Perpajakan (HPP); it uses the same format as
  NIK.

  ## Examples

      iex> NeoFaker.Locales.IdId.Person.npwp()
      "7645504903500640"

  """
  @doc since: "0.14.0"
  @spec npwp() :: String.t()
  defdelegate npwp(), to: __MODULE__, as: :nik
end
