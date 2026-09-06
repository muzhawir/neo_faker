defmodule NeoFaker.Text.EmojiGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @type category ::
          :all
          | :activities
          | :animals_and_nature
          | :food_and_drink
          | :objects
          | :people_and_body
          | :smileys_and_emotion
          | :symbols
          | :travel_and_places

  @emoji_file "emoji.exs"
  # Hardcoded to NeoFaker.Text (not __MODULE__) so NeoFaker.Data resolves
  # priv/data/<locale>/text/emoji.exs instead of a nonexistent
  # priv/data/<locale>/emojigenerator/ directory derived from this module's own name.
  @module NeoFaker.Text

  @doc """
  Generates a random emoji.

  Returns a random emoji from the specified category or all categories if `:all` is passed.
  """
  @spec emoji(category()) :: String.t()
  # :all has no matching key in emoji.exs, so it fetches the whole locale map
  # directly (bypassing the per-category random_value/3 helper) and flattens
  # every category's list into one pool before drawing. Emoji data isn't
  # locale-specific, so this always reads the :default file.
  def emoji(:all) do
    :default
    |> Data.fetch!(@module, @emoji_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def emoji(:activities), do: Data.random_value(@module, @emoji_file, "activities")
  def emoji(:food_and_drink), do: Data.random_value(@module, @emoji_file, "food_and_drink")
  def emoji(:objects), do: Data.random_value(@module, @emoji_file, "objects")
  def emoji(:people_and_body), do: Data.random_value(@module, @emoji_file, "people_and_body")
  def emoji(:symbols), do: Data.random_value(@module, @emoji_file, "symbols")

  def emoji(:animals_and_nature) do
    Data.random_value(@module, @emoji_file, "animals_and_nature")
  end

  def emoji(:smileys_and_emotion) do
    Data.random_value(@module, @emoji_file, "smileys_and_emotion")
  end

  def emoji(:travel_and_places) do
    Data.random_value(@module, @emoji_file, "travel_and_places")
  end
end
