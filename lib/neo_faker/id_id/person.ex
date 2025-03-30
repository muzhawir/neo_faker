defmodule NeoFaker.IdId.Person do
  @moduledoc """
  Provides functions for generating person-related information specific to the Indonesian locale.

  This module offers a variety of functions to generate random personal details specific to
  Indonesia, such as Nomor Induk Kependudukan (NIK), among others.
  """

  alias NeoFaker.IdId.Person.Utils

  @doc """
  Generates a random NIK.

  Returns a random NIK (Nomor Induk Kependudukan).

  ## Examples

      iex> NeoFaker.IdId.Person.nik()
      "7645504903500640"

  """
  @spec nik() :: String.t()
  defdelegate nik(), to: Utils, as: :nik
end
