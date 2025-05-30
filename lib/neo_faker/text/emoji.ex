defmodule NeoFaker.Text.Emoji do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_value: 3]

  alias NeoFaker.Data.Cache

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
  @module NeoFaker.Text

  @doc """
  Generates a random emoji.

  Returns a random emoji from the specified category or all categories if `:all` is passed.
  """
  @spec generate_emoji(category()) :: String.t()
  def generate_emoji(:all) do
    :default
    |> Cache.fetch!(@module, @emoji_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def generate_emoji(:activities), do: random_value(@module, @emoji_file, "activities")
  def generate_emoji(:food_and_drink), do: random_value(@module, @emoji_file, "food_and_drink")
  def generate_emoji(:objects), do: random_value(@module, @emoji_file, "objects")
  def generate_emoji(:people_and_body), do: random_value(@module, @emoji_file, "people_and_body")
  def generate_emoji(:symbols), do: random_value(@module, @emoji_file, "symbols")

  def generate_emoji(:animals_and_nature) do
    random_value(@module, @emoji_file, "animals_and_nature")
  end

  def generate_emoji(:smileys_and_emotion) do
    random_value(@module, @emoji_file, "smileys_and_emotion")
  end

  def generate_emoji(:travel_and_places) do
    random_value(@module, @emoji_file, "travel_and_places")
  end
end
