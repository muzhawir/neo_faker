defmodule NeoFaker.Text.Validator do
  @moduledoc false

  @character_types [:alphabet_lower, :alphabet_upper, :alphabet, :digit]
  @emoji_categories [
    :all,
    :activities,
    :animals_and_nature,
    :food_and_drink,
    :objects,
    :people_and_body,
    :smileys_and_emotion,
    :symbols,
    :travel_and_places
  ]

  @spec validate_character_type!(atom() | nil) :: :ok
  def validate_character_type!(nil), do: :ok

  def validate_character_type!(type) do
    if type in @character_types do
      :ok
    else
      raise ArgumentError,
            "Invalid character type. Expected one of #{inspect(@character_types)}, got: #{inspect(type)}"
    end
  end

  @spec validate_emoji_category!(atom()) :: :ok
  def validate_emoji_category!(category) do
    if category in @emoji_categories do
      :ok
    else
      raise ArgumentError,
            "Invalid emoji category. Expected one of #{inspect(@emoji_categories)}, got: #{inspect(category)}"
    end
  end
end
