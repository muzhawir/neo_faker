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
  @spec character(keyword()) :: String.t()
  def character(opts \\ []) do
    opts = Options.validate!(opts, @character_schema)
    Generator.character(opts[:type])
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
  @spec emoji(keyword()) :: String.t()
  def emoji(opts \\ []) do
    opts = Options.validate!(opts, @emoji_schema)
    EmojiGenerator.emoji(opts[:category])
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
  @spec words(pos_integer(), keyword()) :: [String.t()] | String.t()
  def words(count \\ 5, opts \\ [])

  def words(count, opts) when is_integer(count) and count > 0 do
    opts = Options.validate!(opts, @words_schema)

    words_list = Enum.map(1..count, fn _ -> word() end)

    if opts[:join] do
      Enum.join(words_list, opts[:separator])
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
