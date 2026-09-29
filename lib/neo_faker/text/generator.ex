defmodule NeoFaker.Text.Generator do
  @moduledoc false

  @lower ~c"abcdefghijklmnopqrstuvwxyz"
  @upper ~c"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  @digits ~c"0123456789"

  @pools %{
    nil => @lower ++ @upper ++ @digits,
    alphabet: @lower ++ @upper,
    alphabet_lower: @lower,
    alphabet_upper: @upper,
    digit: @digits
  }

  @type type :: nil | :alphabet | :alphabet_lower | :alphabet_upper | :digit

  @doc """
  Returns a string of `count` random ASCII characters from the pool for `type`.
  `nil` is every letter and digit.
  """
  @spec characters(pos_integer(), type()) :: String.t()
  def characters(count, type) do
    pool = Map.fetch!(@pools, type)
    for _ <- 1..count, into: "", do: <<Enum.random(pool)>>
  end
end
