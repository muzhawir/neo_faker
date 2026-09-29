defmodule NeoFaker.Text do
  @moduledoc """
  Functions for generating characters, words, and emoji.

  For placeholder sentences and paragraphs, see `NeoFaker.Lorem`.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Data
  alias NeoFaker.Text.EmojiGenerator
  alias NeoFaker.Text.Generator

  @word_file "word.exs"

  @character_types [:alphabet_lower, :alphabet_upper, :alphabet, :digit]
  @emoji_categories [
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

  @character_schema NimbleOptions.new!(
                      type: [type: {:in, [nil | @character_types]}, default: nil]
                    )

  @emoji_schema NimbleOptions.new!(category: [type: {:in, @emoji_categories}, default: :all])

  @doc """
  Generates a random ASCII letter or digit, as a one-character string.

  ## Options

    * `:type` (an atom below, or `nil`) - the characters to draw from. Defaults to `nil`,
      any letter or digit.
      * `:alphabet` - any letter, lowercase or uppercase.
      * `:alphabet_lower` - a lowercase letter.
      * `:alphabet_upper` - an uppercase letter.
      * `:digit` - a digit from `0` to `9`.

  ## Examples

      iex> NeoFaker.Text.character()
      "a"

      iex> NeoFaker.Text.character(type: :digit)
      "7"

      iex> NeoFaker.Text.character(type: :alphabet_upper)
      "Q"

  """
  @spec character(keyword()) :: String.t()
  def character(opts \\ []), do: characters(1, opts)

  @doc """
  Generates a string of `count` random ASCII letters or digits.

  `count` defaults to `11`. Raises `ArgumentError` if it is not a positive integer.

  ## Options

    * `:type` - the characters to draw from, as in `character/1`. Defaults to `nil`, any
      letter or digit.

  ## Examples

      iex> NeoFaker.Text.characters()
      "XfELJU1mRMg"

      iex> NeoFaker.Text.characters(5, type: :digit)
      "74392"

      iex> NeoFaker.Text.characters(8, type: :alphabet_lower)
      "qzmvkpth"

  """
  @spec characters(pos_integer(), keyword()) :: String.t()
  def characters(count \\ 11, opts \\ [])

  def characters(count, opts) when is_integer(count) and count > 0 do
    type = opts |> NimbleOptions.validate!(@character_schema) |> Keyword.fetch!(:type)
    Generator.characters(count, type)
  end

  def characters(count, _opts) do
    raise ArgumentError, "count must be a positive integer, got: #{inspect(count)}"
  end

  @doc """
  Generates a random emoji.

  ## Options

    * `:category` (an atom below) - the Unicode emoji category to draw from. Defaults to
      `:all`, every category.
      * `:activities`
      * `:animals_and_nature`
      * `:food_and_drink`
      * `:objects`
      * `:people_and_body`
      * `:smileys_and_emotion`
      * `:symbols`
      * `:travel_and_places`

  ## Examples

      iex> NeoFaker.Text.emoji()
      "✨"

      iex> NeoFaker.Text.emoji(category: :animals_and_nature)
      "🐶"

  """
  @spec emoji(keyword()) :: String.t()
  def emoji(opts \\ []) do
    opts
    |> NimbleOptions.validate!(@emoji_schema)
    |> Keyword.fetch!(:category)
    |> EmojiGenerator.emoji()
  end

  @doc """
  Generates a random common English word.

  A few words contain a hyphen or an apostrophe, such as `"T-shirt"`.

  ## Examples

      iex> NeoFaker.Text.word()
      "computer"

  """
  @spec word() :: String.t()
  def word, do: Data.random_value(__MODULE__, @word_file, "words")

  @doc """
  Generates a list of `count` random common English words.

  `count` defaults to `5`. Raises `ArgumentError` if it is not a positive integer. Use
  `Enum.join/2` if you need a single string.

  ## Examples

      iex> NeoFaker.Text.words(3)
      ["computer", "garden", "river"]

  """
  @spec words(pos_integer()) :: [String.t()]
  def words(count \\ 5)

  def words(count) when is_integer(count) and count > 0,
    do: Enum.map(1..count, fn _ -> word() end)

  def words(count) do
    raise ArgumentError, "count must be a positive integer, got: #{inspect(count)}"
  end
end
