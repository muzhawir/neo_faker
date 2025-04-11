defmodule NeoFaker.EnUs.Person.Utils do
  @moduledoc false

  alias NeoFaker.Number

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
