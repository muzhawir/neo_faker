defmodule NeoFaker.Text.Character do
  @moduledoc false

  @alphabet_lower Enum.shuffle(~w[a b c d e f g h i j k l m n o p q r s t u v w x y z])
  @alphabet_upper Enum.shuffle(~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z])
  @alphabet Enum.shuffle(@alphabet_lower ++ @alphabet_upper)
  @digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9])
  @alphanumeric Enum.shuffle(@alphabet ++ @digits)

  @doc """
  Generates a single random character.

  This function delegates the call to `NeoFaker.Text.character/1`.
  """
  @spec character(Keyword.t()) :: String.t()
  def character(opts \\ [])
  def character([]), do: Enum.random(@alphanumeric)
  def character(type: :alphabet_lower), do: Enum.random(@alphabet_lower)
  def character(type: :alphabet_upper), do: Enum.random(@alphabet_upper)
  def character(type: :alphabet), do: Enum.random(@alphabet)
  def character(type: :digit), do: Enum.random(@digits)
end
