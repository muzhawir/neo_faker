defmodule NeoFaker.Color.HEX do
  @moduledoc false

  @hex_digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9 A B C D E F])

  @doc """
  Generates a random HEX color string of the specified length.

  The resulting string consists of randomly selected hexadecimal digits (0-9, a-f).
  """
  def color(digits) do
    Enum.map_join(1..digits, fn _ -> Enum.random(@hex_digits) end)
  end
end
