defmodule NeoFaker.Text.Emoji do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 3]

  @module NeoFaker.Text
  @emoji_file "emoji.exs"

  @doc """
  Generates a random emoji.

  This function delegates the call to `NeoFaker.Text.emoji/1`.
  """
  @spec emoji(Keyword.t()) :: String.t()
  def emoji([]) do
    :default
    |> fetch_cache!(@module, @emoji_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def emoji(category: :activities), do: random_data(@module, @emoji_file, "activities")
  def emoji(category: :food_and_drink), do: random_data(@module, @emoji_file, "food_and_drink")
  def emoji(category: :objects), do: random_data(@module, @emoji_file, "objects")
  def emoji(category: :people_and_body), do: random_data(@module, @emoji_file, "people_and_body")

  def emoji(category: :animals_and_nature) do
    random_data(@module, @emoji_file, "animals_and_nature")
  end

  def emoji(category: :smileys_and_emotion) do
    random_data(@module, @emoji_file, "smileys_and_emotion")
  end

  def emoji(category: :symbols), do: random_data(@module, @emoji_file, "symbols")

  def emoji(category: :travel_and_places) do
    random_data(@module, @emoji_file, "travel_and_places")
  end
end
