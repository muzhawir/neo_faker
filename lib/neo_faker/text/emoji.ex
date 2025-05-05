defmodule NeoFaker.Text.Emoji do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 3]

  @emoji_file "emoji.exs"
  @module NeoFaker.Text

  @doc """
  Returns a random emoji from all available categories.
  
  Fetches the complete emoji dataset, combines all category lists, and selects a random emoji from the entire collection.
  """
  @spec generate_emoji(:all) :: String.t()
  def generate_emoji(:all) do
    :default
    |> fetch_cache!(@module, @emoji_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  @doc """
Returns a random emoji from the activities category.
"""
def generate_emoji(:activities), do: random_data(@module, @emoji_file, "activities")
  @doc """
Returns a random emoji from the food and drink category.
"""
def generate_emoji(:food_and_drink), do: random_data(@module, @emoji_file, "food_and_drink")
  @doc """
Returns a random emoji from the "objects" category.
"""
def generate_emoji(:objects), do: random_data(@module, @emoji_file, "objects")
  @doc """
Returns a random emoji from the "people and body" category.
"""
@spec generate_emoji(:people_and_body) :: String.t()
def generate_emoji(:people_and_body), do: random_data(@module, @emoji_file, "people_and_body")
  @doc """
Returns a random emoji from the symbols category.
"""
def generate_emoji(:symbols), do: random_data(@module, @emoji_file, "symbols")

  @doc """
  Returns a random emoji from the animals and nature category.
  """
  def generate_emoji(:animals_and_nature) do
    random_data(@module, @emoji_file, "animals_and_nature")
  end

  @doc """
  Returns a random emoji from the "smileys and emotion" category.
  """
  def generate_emoji(:smileys_and_emotion) do
    random_data(@module, @emoji_file, "smileys_and_emotion")
  end

  @doc """
  Returns a random emoji from the travel and places category.
  """
  def generate_emoji(:travel_and_places) do
    random_data(@module, @emoji_file, "travel_and_places")
  end
end
