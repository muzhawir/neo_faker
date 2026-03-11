defmodule NeoFaker.Text do
  @moduledoc """
  Functions for generating random text.

  Provides utilities to generate single characters, multi-character strings,
  emojis, and words from common word lists. All character generators support
  type filtering (alphabet, digits, or mixed alphanumeric).
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Data
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Text.EmojiGenerator

  @default_character_count 11
  @valid_character_types [:alphabet_lower, :alphabet_upper, :alphabet, :digit]
  @valid_emoji_categories [
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
  @word_file "word.exs"
  @alphabet_lower ~w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
  @alphabet_upper ~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
  @digits ~w[0 1 2 3 4 5 6 7 8 9]

  @doc """
  Generates a single random character.

  Returns a single character from the alphanumeric set by default. Use the
  `:type` option to restrict the pool.

  ## Options

  - `:type` - Character pool to draw from. Defaults to the full alphanumeric set.
    - `:alphabet_lower` - Lowercase letters only.
    - `:alphabet_upper` - Uppercase letters only.
    - `:alphabet` - Any letter (lower or upper).
    - `:digit` - A digit (`0`–`9`).

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
  def character([]), do: Enum.random(Enum.shuffle(@alphabet_lower ++ @alphabet_upper ++ @digits))

  def character(opts) when is_list(opts) do
    type = Options.get(opts, :type, nil)
    validate_character_type!(type)
    generate_character_by_type(type)
  end

  @doc """
  Generates a string of random characters.

  Calls `character/1` `number` times and joins the results into a single string.

  ## Parameters

  - `number` - Number of characters to generate. Defaults to `11`.

  ## Options

  - `:type` - Character pool to draw from (see `character/1`). Defaults to alphanumeric.

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
  def characters(number \\ @default_character_count, opts \\ [])

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

  Returns a random emoji from the specified category, or from all categories
  when `:all` is used (default).

  ## Options

  - `:category` - Emoji category. Defaults to `:all`.
    - `:all` - Any category.
    - `:activities` - Activities.
    - `:animals_and_nature` - Animals and nature.
    - `:food_and_drink` - Food and drink.
    - `:objects` - Objects.
    - `:people_and_body` - People and body.
    - `:smileys_and_emotion` - Smileys and emotion.
    - `:symbols` - Symbols.
    - `:travel_and_places` - Travel and places.

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
  Generates a random word from a common English word list.

  ## Examples

      iex> NeoFaker.Text.word()
      "computer"

  """
  @spec word() :: String.t()
  def word do
    Data.random_value(__MODULE__, @word_file, "words")
  end

  @doc """
  Generates multiple random words.

  Returns a list of words by default. Pass `join: true` to get a single string.

  ## Parameters

  - `count` - Number of words to generate. Defaults to `5`.

  ## Options

  - `:join` - When `true`, joins the words into a string. Defaults to `false`.
  - `:separator` - Separator used when joining. Defaults to `" "`.

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
  defp generate_character_by_type(nil),
    do: Enum.random(Enum.shuffle(@alphabet_lower ++ @alphabet_upper ++ @digits))

  defp generate_character_by_type(:alphabet_lower), do: Enum.random(Enum.shuffle(@alphabet_lower))
  defp generate_character_by_type(:alphabet_upper), do: Enum.random(Enum.shuffle(@alphabet_upper))

  defp generate_character_by_type(:alphabet),
    do: Enum.random(Enum.shuffle(@alphabet_lower ++ @alphabet_upper))

  defp generate_character_by_type(:digit), do: Enum.random(Enum.shuffle(@digits))

  @spec validate_character_type!(atom() | nil) :: :ok
  defp validate_character_type!(nil), do: :ok

  defp validate_character_type!(type) do
    if type in @valid_character_types do
      :ok
    else
      raise ArgumentError,
            "Invalid character type. Expected one of #{inspect(@valid_character_types)}, got: #{inspect(type)}"
    end
  end

  @spec validate_emoji_category!(atom()) :: :ok
  defp validate_emoji_category!(category) do
    if category in @valid_emoji_categories do
      :ok
    else
      raise ArgumentError,
            "Invalid emoji category. Expected one of #{inspect(@valid_emoji_categories)}, got: #{inspect(category)}"
    end
  end
end
