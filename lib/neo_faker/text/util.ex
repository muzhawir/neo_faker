defmodule NeoFaker.Text.Util do
  @moduledoc false

  import NeoFaker.Helper.Generator, only: [random: 4]

  alias NeoFaker.Helper.Locale

  @module NeoFaker.Text
  @alphabet_lower Enum.shuffle(~w[a b c d e f g h i j k l m n o p q r s t u v w x y z])
  @alphabet_upper Enum.shuffle(~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z])
  @alphabet Enum.shuffle(@alphabet_lower ++ @alphabet_upper)
  @digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9])
  @alphanumeric Enum.shuffle(@alphabet ++ @digits)
  @emoji_file "emoji.exs"

  @doc """
  Generates a single random character.

  This function delegates the call to `NeoFaker.Text.Util.character/1`.
  """
  @spec character(Keyword.t()) :: String.t()
  def character(opts \\ [])
  def character([]), do: Enum.random(@alphanumeric)
  def character(type: :alphabet_lower), do: Enum.random(@alphabet_lower)
  def character(type: :alphabet_upper), do: Enum.random(@alphabet_upper)
  def character(type: :alphabet), do: Enum.random(@alphabet)
  def character(type: :digit), do: Enum.random(@digits)

  @doc """
  Generates a random emoji.

  This function delegates the call to `NeoFaker.Text.Util.emoji/1`.
  """
  @spec emoji(Keyword.t()) :: String.t()
  def emoji([]) do
    @module
    |> Locale.load_persistent_term(@emoji_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def emoji(category: :activities), do: random(@module, @emoji_file, "activities", [])
  def emoji(category: :food_and_drink), do: random(@module, @emoji_file, "food_and_drink", [])
  def emoji(category: :objects), do: random(@module, @emoji_file, "objects", [])
  def emoji(category: :people_and_body), do: random(@module, @emoji_file, "people_and_body", [])

  def emoji(category: :animals_and_nature) do
    random(@module, @emoji_file, "animals_and_nature", [])
  end

  def emoji(category: :smileys_and_emotion) do
    random(@module, @emoji_file, "smileys_and_emotion", [])
  end

  def emoji(category: :symbols), do: random(@module, @emoji_file, "symbols", [])

  def emoji(category: :travel_and_places) do
    random(@module, @emoji_file, "travel_and_places", [])
  end
end
