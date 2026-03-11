defmodule NeoFaker.Text.Generator do
  @moduledoc false

  import Enum, only: [random: 1, shuffle: 1]

  @alphabet_lower ~w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
  @alphabet_upper ~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
  @digits ~w[0 1 2 3 4 5 6 7 8 9]

  @doc """
  Generates a random character based on the specified type.

  - `nil` - returns a random character from lowercase letters, uppercase letters, and digits.
  - `:alphabet_lower` - returns a random lowercase letter.
  - `:alphabet_upper` - returns a random uppercase letter.
  - `:alphabet` - returns a random letter (lowercase or uppercase).
  - `:digit` - returns a random digit character.
  """
  @spec character(atom() | nil) :: String.t()
  def character(nil), do: random(shuffle(@alphabet_lower ++ @alphabet_upper ++ @digits))
  def character(:alphabet_lower), do: random(shuffle(@alphabet_lower))
  def character(:alphabet_upper), do: random(shuffle(@alphabet_upper))
  def character(:alphabet), do: random(shuffle(@alphabet_lower ++ @alphabet_upper))
  def character(:digit), do: random(shuffle(@digits))
end
