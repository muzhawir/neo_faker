defmodule NeoFaker.EnUs.Person.Utils do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generate a random SSN.

  This function delegates the call to `NeoFaker.EnUs.Person.ssn/0`.
  """
  @spec ssn() :: String.t()
  def ssn do
    group_number = 1 |> Number.between(99) |> to_string() |> String.pad_leading(2, "0")
    serial_number = 1 |> Number.between(9999) |> to_string() |> String.pad_leading(4, "0")

    "#{area_number()}-#{group_number}-#{serial_number}"
  end

  # Generate a random area number, if the area number is 666 replace it with 777
  defp area_number do
    number = Number.between(1, 899)

    case number do
      666 -> "777"
      _ -> number |> to_string() |> String.pad_leading(3, "0")
    end
  end
end
