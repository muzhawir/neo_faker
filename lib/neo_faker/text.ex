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
Generates a single random character, optionally specifying the character type.

By default, returns a random alphanumeric character. The `:type` option can be used to restrict the result to lowercase letters, uppercase letters, letters of any case, or digits.

## Options

  - `:type` (optional):  
    - `:alphabet_lower` — returns a lowercase letter  
    - `:alphabet_upper` — returns an uppercase letter  
    - `:alphabet` — returns a letter (lowercase or uppercase)  
    - `:digit` — returns a digit (`0`–`9`)

## Examples

    iex> NeoFaker.Text.character()
    "a"

    iex> NeoFaker.Text.character(type: :digit)
    "0"
"""
def character(opts \\ [])
  @doc """
Returns a random alphanumeric character as a string.

Selects a single character from the set of uppercase letters, lowercase letters, and digits.
"""
def character([]), do: Enum.random(@alphanumeric)
  @doc """
Returns a random lowercase alphabetic character.
"""
def character(type: :alphabet_lower), do: Enum.random(@alphabet_lower)
  @doc """
Returns a random uppercase alphabetic character.
"""
def character(type: :alphabet_upper), do: Enum.random(@alphabet_upper)
  @doc """
Returns a random alphabetic character (uppercase or lowercase).

Selects a single character from the combined list of uppercase and lowercase English letters.
"""
def character(type: :alphabet), do: Enum.random(@alphabet)
  @doc """
Returns a random digit character as a string.

Selects a single character from the set of digits 0–9.
"""
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
Generates a random emoji, optionally limited to a specified category.

If no category is provided, returns an emoji from any available category.

## Options

  - `:category` (atom) – Restricts the emoji to a specific category. Valid categories include:
    - `:all` (default)
    - `:activities`
    - `:animals_and_nature`
    - `:food_and_drink`
    - `:objects`
    - `:people_and_body`
    - `:smileys_and_emotion`
    - `:symbols`
    - `:travel_and_places`

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
