defmodule NeoFaker.Text do
  @moduledoc """
  Provides functions for generating text.

  This module includes functions for generating random text, such as alphanumeric characters and
  emojis.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Text.Util

  @doc """
  Generates a single random character.

  Returns a single alphanumeric character.

  ## Options

  The accepted options are:

  - `:type` - Specifies the type of character to generate.

  The values for `:type` can be:

  - `:alphabet_lower` - A lowercase letter.
  - `:alphabet_upper` - An uppercase letter.
  - `:alphabet` - A letter (either lowercase or uppercase).
  - `:digit` - A digit (`0`-`9`).

  ## Examples

      iex> NeoFaker.Text.character()
      "a"

      iex> NeoFaker.Text.character(type: :digit)
      "0"

  """
  @spec character(Keyword.t()) :: String.t()
  defdelegate character(opts \\ []), to: Util, as: :character

  @doc """
  Generates a string of random characters.

  Returns a string of the specified length containing randomly selected characters.

  ## Options

  See `character/1` for available options.

  ## Examples

      iex> NeoFaker.Text.characters()
      "XfELJU1mRMg"

      iex> NeoFaker.Text.characters(20, type: :alphabet_upper)
      "BVAJHRGSCEVJFNYSWCJE"

  """
  @spec characters(non_neg_integer(), Keyword.t()) :: String.t()
  def characters(number \\ 11, opts \\ []) do
    Enum.map_join(1..number, fn _ -> character(opts) end)
  end

  @doc """
  Generates a random emoji.

  Returns a random emoji from any category if no category is specified; otherwise, it selects one
  from the specified category.

  ## Options

  The accepted options are:

  - `:category` - Specifies the category from which to generate an emoji.

  The values for `:category` can be:

  - `:activities` - An emoji related to activities.
  - `:animals_and_nature` - An emoji related to animals and nature.
  - `:food_and_drink` - An emoji related to food and drink.
  - `:objects` - An emoji related to objects.
  - `:people_and_body` - An emoji related to people and body.
  - `:smileys_and_emotion` - An emoji related to smileys and emotion.
  - `:symbols` - An emoji related to symbols.
  - `:travel_and_places` - An emoji related to travel and places.

  ## Examples

      iex> NeoFaker.Text.emoji()
      "✨"

      iex> NeoFaker.Text.emoji(category: :activities)
      "🎉"

  """
  @spec emoji(Keyword.t()) :: String.t()
  defdelegate emoji(opts \\ []), to: Util, as: :emoji
end
