defmodule NeoFaker.Text do
  @moduledoc """
  Functions for generating text.

  This module provides utilities to generate random text, including alphanumeric characters and
  emojis.
  """
  @moduledoc since: "0.8.0"

  import NeoFaker.Data.Generator, only: [random_data: 3]
  import NeoFaker.Text.Emoji

  @alphabet_lower Enum.shuffle(~w[a b c d e f g h i j k l m n o p q r s t u v w x y z])
  @alphabet_upper Enum.shuffle(~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z])
  @alphabet Enum.shuffle(@alphabet_lower ++ @alphabet_upper)
  @digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9])
  @alphanumeric Enum.shuffle(@alphabet ++ @digits)
  @word_file "word.exs"

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
  def character(opts \\ [])
  def character([]), do: Enum.random(@alphanumeric)
  def character(type: :alphabet_lower), do: Enum.random(@alphabet_lower)
  def character(type: :alphabet_upper), do: Enum.random(@alphabet_upper)
  def character(type: :alphabet), do: Enum.random(@alphabet)
  def character(type: :digit), do: Enum.random(@digits)

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

  - `:all` - An emoji from any category (default).
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
  def emoji(opts \\ []), do: generate_emoji(Keyword.get(opts, :category, :all))

  @doc """
  Generates a random word.

  Returns a random word from common word lists.

  ## Examples

      iex> NeoFaker.Text.word()
      "computer"

  """
  @doc since: "0.9.0"
  @spec word() :: String.t()
  def word, do: random_data(__MODULE__, @word_file, "words")
end
