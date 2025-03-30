defmodule NeoFaker.IdId.Person do
  @moduledoc """
  Provides functions for generating Indonesian locale specific person-related information.

  This module offers a variety of functions to generate random personal details specific to
  the Indonesian locale, such as NIK (Nomor Induk Kependudukan), etc.
  """

  alias NeoFaker.IdId.Person.Utils

  @doc """
  Generate a random NIK.

  Returns a random NIK (Nomor Induk Kependudukan).

  ## Examples

      iex> NeoFaker.IdId.Person.nik()
      "7645504903500640"

  """
  @spec nik() :: String.t()
  defdelegate nik(), to: Utils, as: :nik
end
