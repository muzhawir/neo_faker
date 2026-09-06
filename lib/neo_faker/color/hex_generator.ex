defmodule NeoFaker.Color.HexGenerator do
  @moduledoc false

  @hex_digits ~w[0 1 2 3 4 5 6 7 8 9 A B C D E F]

  @doc """
  Generates `digits` random hex characters. Digits are uppercase (A-F), never lowercase.
  """
  @spec color(3 | 4 | 6 | 8) :: String.t()
  def color(digits) when digits in [3, 4, 6, 8] do
    Enum.map_join(1..digits, fn _ -> Enum.random(@hex_digits) end)
  end
end
