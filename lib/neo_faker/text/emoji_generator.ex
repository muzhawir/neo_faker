defmodule NeoFaker.Text.EmojiGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @categories ~w[
    activities
    animals_and_nature
    food_and_drink
    objects
    people_and_body
    smileys_and_emotion
    symbols
    travel_and_places
  ]

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

  @doc """
  Returns a random emoji from `category`, or from every category for `:all`.
  """
  @spec emoji(category()) :: String.t()
  def emoji(:all), do: random(@categories)
  def emoji(category), do: random(Atom.to_string(category))

  defp random(keys), do: Data.random_value(NeoFaker.Text, "emoji.exs", keys, locale: :default)
end
