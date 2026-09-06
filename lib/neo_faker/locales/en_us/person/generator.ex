defmodule NeoFaker.Locales.EnUs.Person.Generator do
  @moduledoc false

  # Building blocks assembled by NeoFaker.Locales.EnUs.Person.ssn/0 into the
  # AAA-GG-SSSS format.

  alias NeoFaker.Number

  @doc """
  Generates a zero-padded random number, used for the group and serial parts
  of an SSN.
  """
  @spec serial_number(non_neg_integer(), non_neg_integer()) :: String.t()
  def serial_number(max_number, pad_count) do
    1 |> Number.between(max_number) |> to_string() |> String.pad_leading(pad_count, "0")
  end

  @doc """
  Generates a random 3-digit SSN area number as a zero-padded string.

  Real SSN area numbers are never in the 900-999 range, so the draw is
  capped at 899; 666 is also never issued, so that value is swapped for 777.
  """
  @spec area_number() :: String.t()
  def area_number do
    number = Number.between(1, 899)

    case number do
      666 -> "777"
      _ -> number |> to_string() |> String.pad_leading(3, "0")
    end
  end
end
