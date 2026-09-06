defmodule NeoFaker.Text do
  @moduledoc """
  Functions for generating random text.

  Provides utilities to generate single characters, multi-character strings,
  emojis, and words from common word lists. All character generators support
  type filtering (alphabet, digits, or mixed alphanumeric).
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Data
  alias NeoFaker.Text.EmojiGenerator
  alias NeoFaker.Text.Generator

  @word_file "word.exs"

  @character_count 11

  @character_schema NimbleOptions.new!(
                      type: [
                        type: {:in, [nil, :alphabet_lower, :alphabet_upper, :alphabet, :digit]},
                        default: nil
                      ]
                    )

  @emoji_schema NimbleOptions.new!(
                  category: [
                    type:
                      {:in,
                       [
                         :all,
                         :activities,
                         :animals_and_nature,
                         :food_and_drink,
                         :objects,
                         :people_and_body,
                         :smileys_and_emotion,
                         :symbols,
                         :travel_and_places
                       ]},
                    default: :all
                  ]
                )

  @words_schema NimbleOptions.new!(
                  join: [type: :boolean, default: false],
                  separator: [type: :string, default: " "]
                )

  @doc """
  Generates a single random character.

  Returns a single character from the alphanumeric set by default.

  ## Options

    * `:type` (an atom below, or `nil`) - the character pool to draw from. Defaults to `nil`
      (the full alphanumeric set).
      * `:alphabet_lower` - lowercase letters only.
      * `:alphabet_upper` - uppercase letters only.
      * `:alphabet` - any letter (lower or upper).
      * `:digit` - a digit (`0`–`9`).

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
  @spec character(keyword()) :: String.t()
  def character(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @character_schema)
    Generator.character(Keyword.fetch!(opts, :type))
  end

  @doc """
  Generates a string of random characters.

  Calls `character/1` `number` times and joins the results into a single string. `number`
  defaults to `11`.

  ## Options

    * `:type` (see `character/1`'s `:type` option) - the character pool to draw from.
      Defaults to `nil` (the full alphanumeric set).

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
  @spec characters(pos_integer(), keyword()) :: String.t()
  def characters(number \\ @character_count, opts \\ [])

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

  Returns a random emoji from the specified category, or from all categories by default.

  ## Options

    * `:category` (an atom below) - the emoji category. Defaults to `:all`.
      * `:all` - any category.
      * `:activities` - activities.
      * `:animals_and_nature` - animals and nature.
      * `:food_and_drink` - food and drink.
      * `:objects` - objects.
      * `:people_and_body` - people and body.
      * `:smileys_and_emotion` - smileys and emotion.
      * `:symbols` - symbols.
      * `:travel_and_places` - travel and places.

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
  @spec emoji(keyword()) :: String.t()
  def emoji(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @emoji_schema)
    EmojiGenerator.emoji(Keyword.fetch!(opts, :category))
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

  Returns a list of words by default. `count` sets how many are generated and defaults to `5`.

  ## Options

    * `:join` (boolean) - when `true`, joins the words into a single string instead of
      returning a list. Defaults to `false`.
    * `:separator` (string) - the separator used when joining. Defaults to `" "`.

  ## Examples

      iex> NeoFaker.Text.words(3)
      ["computer", "elixir", "phoenix"]

      iex> NeoFaker.Text.words(3, join: true)
      "computer elixir phoenix"

      iex> NeoFaker.Text.words(3, join: true, separator: "-")
      "computer-elixir-phoenix"

  """
  @spec words(pos_integer(), keyword()) :: [String.t()] | String.t()
  def words(count \\ 5, opts \\ [])

  def words(count, opts) when is_integer(count) and count > 0 do
    opts = NimbleOptions.validate!(opts, @words_schema)

    words_list = Enum.map(1..count, fn _ -> word() end)

    if Keyword.fetch!(opts, :join) do
      Enum.join(words_list, Keyword.fetch!(opts, :separator))
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
end
