defmodule NeoFaker.Locales.EnUs.Person.Generator do
  @moduledoc false

  # Parts of a Social Security Number, AAA-GG-SSSS. The Social Security
  # Administration never issues area 000, 666, or 900-999, group 00, or
  # serial 0000.

  @doc """
  Returns a random number from `1..max`, zero-padded to `width` digits.
  """
  @spec serial_number(pos_integer(), pos_integer()) :: String.t()
  def serial_number(max, width) do
    1..max |> Enum.random() |> Integer.to_string() |> String.pad_leading(width, "0")
  end

  @doc """
  Returns a random three-digit area number from `001` to `899`, excluding `666`.
  """
  @spec area_number() :: String.t()
  def area_number do
    # Draw from the 898 valid values and shift the upper part past 666, so no
    # area number is more likely than another.
    area = Enum.random(1..898)
    area = if area >= 666, do: area + 1, else: area

    area |> Integer.to_string() |> String.pad_leading(3, "0")
  end
end
