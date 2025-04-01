defmodule NeoFaker.IdId.Person do
  @moduledoc """
  Functions for generating person-related information specific to Indonesia.

  This module provides utilities to generate random personal details specific to Indonesia, such
  as Nomor Induk Kependudukan (NIK).
  """
  @moduledoc since: "0.9.0"

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
