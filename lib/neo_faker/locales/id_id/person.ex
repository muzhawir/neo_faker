defmodule NeoFaker.Locales.IdId.Person do
  @moduledoc """
  Functions for generating personal details specific to Indonesia.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Locales.IdId.Person.Generator

  @doc """
  Generates a random Nomor Induk Kependudukan (NIK), the Indonesian resident identity
  number.

  The result is a 16-digit string made of three parts:

    * a six-digit district (kecamatan) code: two digits each for the province, the regency
      or city, and the district. Codes are drawn from the official list in Kepmendagri
      No. 300.2.2-2430 Tahun 2025, so every code names a real district.
    * the date of birth as `DDMMYY`, with 40 added to the day for women, for a person aged
      18 to 90.
    * a four-digit serial number, from `0001` to `9999`.

  The number is structurally valid but random, so it may coincide with a real person's
  NIK. Do not use it outside test and development data.

  ## Examples

      iex> NeoFaker.Locales.IdId.Person.nik()
      "3273014903950042"

  """
  @spec nik() :: String.t()
  def nik do
    Generator.region_code() <> Generator.birth_date() <> Generator.serial_number(9999, 4)
  end

  @doc """
  Generates a random Nomor Pokok Wajib Pajak (NPWP), the Indonesian taxpayer number.

  Since UU No. 7 Tahun 2021 on the Harmonization of Tax Regulations (HPP), an
  individual's NPWP is their NIK, so this returns a value in the same 16-digit format as
  `nik/0`.

  ## Examples

      iex> NeoFaker.Locales.IdId.Person.npwp()
      "3273014903950042"

  """
  @doc since: "0.14.0"
  @spec npwp() :: String.t()
  def npwp, do: nik()
end
