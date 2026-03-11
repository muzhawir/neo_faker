defmodule NeoFaker.Text do
  @moduledoc """
  Functions for generating text.

  This module provides utilities to generate random text, including alphanumeric characters,
  emojis, and words.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Data
  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Text.EmojiGenerator

  @doc """
  Generates a single random character.

  Returns a single alphanumeric character such as a letter or digit. If no options are provided,
  it randomly selects from the full alphanumeric set.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Specifies the type of character to generate. Defaults to alphanumeric.

  ## Options

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

      iex> NeoFaker.Text.character(type: :alphabet_lower)
      "z"

      iex> NeoFaker.Text.character(type: :alphabet_upper)
      "A"

      iex> NeoFaker.Text.character(type: :alphabet)
      "X"

  """
  @spec character(Keyword.t()) :: String.t()
  def character(opts \\ [])
  def character([]), do: Enum.random(Constants.alphanumeric())

  def character(opts) when is_list(opts) do
    type = Options.get(opts, :type, nil)
    validate_character_type!(type)
    generate_character_by_type(type)
  end

  @doc """
  Generates a string of random characters.

  Returns a string of the specified length containing randomly selected characters.

  ## Parameters

  - `number` - The number of characters to generate. Defaults to `11`.
  - `opts` - Keyword list of options:
    - `:type` - Specifies the type of character to generate.

  ## Options

  The values for `:type` can be:

  - `:alphabet_lower` - Lowercase letters only.
  - `:alphabet_upper` - Uppercase letters only.
  - `:alphabet` - Letters (lowercase or uppercase).
  - `:digit` - Digits (`0`-`9`) only.

  ## Examples

      iex> NeoFaker.Text.characters()
      "XfELJU1mRMg"

      iex> NeoFaker.Text.characters(20, type: :alphabet_upper)
      "BVAJHRGSCEVJFNYSWCJE"

      iex> NeoFaker.Text.characters(5, type: :digit)
      "74392"

      iex> NeoFaker.Text.characters(10, type: :alphabet_lower)
      "xyzabcdefg"

  """
  @spec characters(pos_integer(), Keyword.t()) :: String.t()
  def characters(number \\ Constants.default_character_count(), opts \\ [])

  def characters(number, opts) when is_integer(number) and number > 0 and is_list(opts) do
    Enum.map_join(1..number, fn _ -> character(opts) end)
  end

  def characters(number, _opts) when is_integer(number) do
    raise ArgumentError, "number must be a positive integer, got: #{number}"
  end

  def characters(number, _opts) do
    raise ArgumentError, "number must be a positive integer, got: #{inspect(number)}"
  end

  @doc """
  Generates a random emoji.

  Returns a random emoji from any category if no category is specified; otherwise, it selects one
  from the specified category.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:category` - Specifies the category from which to generate an emoji. Defaults to `:all`.

  ## Options

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

      iex> NeoFaker.Text.emoji(category: :smileys_and_emotion)
      "😀"

      iex> NeoFaker.Text.emoji(category: :animals_and_nature)
      "🐶"

  """
  @spec emoji(Keyword.t()) :: String.t()
  def emoji(opts \\ []) do
    category = Options.get(opts, :category, :all)
    validate_emoji_category!(category)
    EmojiGenerator.emoji(category)
  end

  @doc """
  Generates a random word.

  Returns a random word from common word lists.

  ## Examples

      iex> NeoFaker.Text.word()
      "computer"

      iex> NeoFaker.Text.word()
      "elixir"

  """
  @spec word() :: String.t()
  def word do
    Data.random_value(__MODULE__, Constants.word_file(), "words")
  end

  @doc """
  Generates multiple random words.

  Returns a list of random words, or a joined string if the `:join` option is true.

  ## Parameters

  - `count` - The number of words to generate. Defaults to `5`.
  - `opts` - Keyword list of options:
    - `:join` - When `true`, joins words with spaces. Defaults to `false`.
    - `:separator` - The separator to use when joining. Defaults to `" "`.

  ## Examples

      iex> NeoFaker.Text.words(3)
      ["computer", "elixir", "phoenix"]

      iex> NeoFaker.Text.words(3, join: true)
      "computer elixir phoenix"

      iex> NeoFaker.Text.words(3, join: true, separator: "-")
      "computer-elixir-phoenix"

  """
  @spec words(pos_integer(), Keyword.t()) :: [String.t()] | String.t()
  def words(count \\ 5, opts \\ [])

  def words(count, opts) when is_integer(count) and count > 0 do
    join = Options.get(opts, :join, false)

    words_list = Enum.map(1..count, fn _ -> word() end)

    if join do
      Enum.join(words_list, Options.get(opts, :separator, " "))
    else
      words_list
    end
  end

  def words(count, _opts) when is_integer(count) do
    raise ArgumentError, "count must be a positive integer, got: #{count}"
  end

  def words(count, _opts) do
    raise ArgumentError, "count must be a positive integer, got: #{inspect(count)}"
  end

  # Private functions

  @spec generate_character_by_type(atom() | nil) :: String.t()
  defp generate_character_by_type(nil), do: Enum.random(Constants.alphanumeric())
  defp generate_character_by_type(:alphabet_lower), do: Enum.random(Constants.alphabet_lower())
  defp generate_character_by_type(:alphabet_upper), do: Enum.random(Constants.alphabet_upper())
  defp generate_character_by_type(:alphabet), do: Enum.random(Constants.alphabet())
  defp generate_character_by_type(:digit), do: Enum.random(Constants.digits())

  @spec validate_character_type!(atom() | nil) :: :ok
  defp validate_character_type!(nil), do: :ok

  defp validate_character_type!(type) do
    valid_types = Constants.valid_character_types()

    if type in valid_types do
      :ok
    else
      raise ArgumentError,
            "Invalid character type. Expected one of #{inspect(valid_types)}, got: #{inspect(type)}"
    end
  end

  @spec validate_emoji_category!(atom()) :: :ok
  defp validate_emoji_category!(category) do
    valid_categories = Constants.valid_emoji_categories()

    if category in valid_categories do
      :ok
    else
      raise ArgumentError,
            "Invalid emoji category. Expected one of #{inspect(valid_categories)}, got: #{inspect(category)}"
    end
  end
end
