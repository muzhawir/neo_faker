defmodule NeoFaker.Locales.IdId.Person do
  @moduledoc """
  Functions for generating personal details specific to Indonesia.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Locales.IdId.Person.Generator

  @doc """
  Generates a random Nomor Induk Kependudukan (NIK), the Indonesian resident identity
  number.

  The result is a 16-digit string: a six-digit region code, the birth date as `DDMMYY`
  (with 40 added to the day for women), and a four-digit serial. Region codes are drawn
  from plausible ranges, not from the official list, so a code may not exist.

  ## Examples

      iex> NeoFaker.Locales.IdId.Person.nik()
      "7645504903500640"

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
      "7645504903500640"

  """
  @doc since: "0.14.0"
  @spec npwp() :: String.t()
  def npwp, do: nik()
end
