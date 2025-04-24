defmodule NeoFaker.EnUs.Person.Utils do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generate a serial number with a specified maximum number and padding count.
  """
  @spec serial_number(non_neg_integer(), non_neg_integer()) :: String.t()
  def serial_number(max_number, pad_count) do
    1 |> Number.between(max_number) |> to_string() |> String.pad_leading(pad_count, "0")
  end

  @doc """
  Generate a random area number, if the area number is 666 replace it with 777.
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
