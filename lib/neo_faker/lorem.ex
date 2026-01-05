defmodule NeoFaker.Lorem do
  @moduledoc """
  Functions for generating random text using a Lorem Ipsum generator.

  This module provides utilities to generate random text, such as paragraphs, sentences, and
  words from various text sources.
  """
  @moduledoc since: "0.8.0"

  import NeoFaker.Data.Generator, only: [random_value: 4]

  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Options

  @doc """
  Generates a random paragraph.

  Returns a random Lorem Ipsum paragraph. The paragraph is sourced from a specific text file
  based on the provided options.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:text` - Specifies the text source. Defaults to `:lorem`.

  ## Options

  Values for option `:text` can be:

  - `:lorem` - A standard Lorem Ipsum text (default).
  - `:meditations` - A meditation text by Marcus Aurelius.

  ## Examples

      iex> NeoFaker.Lorem.paragraph()
      "Suspendisse ac justo venenatis, tincidunt sapien nec, accumsan augue. Vestibulum urna
      risus, egestas ut ultrices non, aliquet eget massa. Mauris id diam eget augue sagittis
      convallis sit amet nec diam. Morbi ut blandit est, et placerat neque."

      iex> NeoFaker.Lorem.paragraph(text: :meditations)
      "Do the things external which fall upon thee distract thee? Give thyself time to learn
      something new and good, and cease to be whirled around. But then thou must also avoid being
      carried about the other way. For those too are triflers who have wearied themselves in life
      by their activity, and yet have no object to which to direct every movement, and, in a word,
      all their thoughts."

      iex> NeoFaker.Lorem.paragraph(text: :lorem)
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

  """
  @spec paragraph(Keyword.t()) :: String.t()
  def paragraph(opts \\ []) do
    text_source = Options.get(opts, :text, :lorem)
    validate_text_source!(text_source)

    file = get_text_file(text_source)

    __MODULE__
    |> random_value(file, "text", opts)
    |> normalize_text()
    |> extract_paragraph()
  end

  @doc """
  Generates a random sentence.

  Returns a single random sentence from the specified text source. The sentence is extracted
  from a paragraph and properly delimited.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:text` - Specifies the text source. Defaults to `:lorem`.

  ## Options

  Values for option `:text` can be:

  - `:lorem` - A standard Lorem Ipsum text (default).
  - `:meditations` - A meditation text by Marcus Aurelius.

  ## Examples

      iex> NeoFaker.Lorem.sentence()
      "Suspendisse ac justo venenatis, tincidunt sapien nec, accumsan augue."

      iex> NeoFaker.Lorem.sentence(text: :meditations)
      "Do the things external which fall upon thee distract thee?"

      iex> NeoFaker.Lorem.sentence(text: :lorem)
      "Lorem ipsum dolor sit amet."

  """
  @spec sentence(Keyword.t()) :: String.t()
  def sentence(opts \\ []) do
    opts |> paragraph() |> split_into_sentences() |> Enum.random()
  end

  @doc """
  Generates a random word.

  Returns a single random word from the specified text source. The word is extracted from
  a sentence and cleaned of punctuation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:text` - Specifies the text source. Defaults to `:lorem`.

  ## Options

  Values for option `:text` can be:

  - `:lorem` - A standard Lorem Ipsum text (default).
  - `:meditations` - A meditation text by Marcus Aurelius.

  ## Examples

      iex> NeoFaker.Lorem.word()
      "suspendisse"

      iex> NeoFaker.Lorem.word(text: :meditations)
      "distract"

      iex> NeoFaker.Lorem.word(text: :lorem)
      "ipsum"

  """
  @spec word(Keyword.t()) :: String.t()
  def word(opts \\ []) do
    opts
    |> sentence()
    |> remove_punctuation()
    |> split_into_words()
    |> Enum.random()
    |> String.downcase()
  end

  @doc """
  Generates multiple random paragraphs.

  Returns a list of random paragraphs from the specified text source.

  ## Parameters

  - `count` - The number of paragraphs to generate. Defaults to `3`.
  - `opts` - Keyword list of options:
    - `:text` - Specifies the text source. Defaults to `:lorem`.
    - `:join` - When `true`, joins paragraphs with newlines. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Lorem.paragraphs(2)
      ["First paragraph...", "Second paragraph..."]

      iex> NeoFaker.Lorem.paragraphs(2, text: :meditations)
      ["First meditation...", "Second meditation..."]

      iex> NeoFaker.Lorem.paragraphs(2, join: true)
      "First paragraph...\\n\\nSecond paragraph..."

  """
  @spec paragraphs(pos_integer(), Keyword.t()) :: [String.t()] | String.t()
  def paragraphs(count \\ 3, opts \\ []) when is_integer(count) and count > 0 do
    paragraphs_list = Enum.map(1..count, fn _ -> paragraph(opts) end)

    if Options.get(opts, :join, false) do
      Enum.join(paragraphs_list, "\n\n")
    else
      paragraphs_list
    end
  end

  @doc """
  Generates multiple random sentences.

  Returns a list of random sentences from the specified text source.

  ## Parameters

  - `count` - The number of sentences to generate. Defaults to `5`.
  - `opts` - Keyword list of options:
    - `:text` - Specifies the text source. Defaults to `:lorem`.
    - `:join` - When `true`, joins sentences with spaces. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Lorem.sentences(3)
      ["First sentence.", "Second sentence.", "Third sentence."]

      iex> NeoFaker.Lorem.sentences(3, text: :meditations)
      ["First meditation.", "Second meditation.", "Third meditation."]

      iex> NeoFaker.Lorem.sentences(3, join: true)
      "First sentence. Second sentence. Third sentence."

  """
  @spec sentences(pos_integer(), Keyword.t()) :: [String.t()] | String.t()
  def sentences(count \\ 5, opts \\ []) when is_integer(count) and count > 0 do
    sentences_list = Enum.map(1..count, fn _ -> sentence(opts) end)

    if Options.get(opts, :join, false) do
      Enum.join(sentences_list, " ")
    else
      sentences_list
    end
  end

  @doc """
  Generates multiple random words.

  Returns a list of random words from the specified text source.

  ## Parameters

  - `count` - The number of words to generate. Defaults to `10`.
  - `opts` - Keyword list of options:
    - `:text` - Specifies the text source. Defaults to `:lorem`.
    - `:join` - When `true`, joins words with spaces. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Lorem.words(5)
      ["word1", "word2", "word3", "word4", "word5"]

      iex> NeoFaker.Lorem.words(5, text: :meditations)
      ["meditation1", "meditation2", "meditation3", "meditation4", "meditation5"]

      iex> NeoFaker.Lorem.words(5, join: true)
      "word1 word2 word3 word4 word5"

  """
  @spec words(pos_integer(), Keyword.t()) :: [String.t()] | String.t()
  def words(count \\ 10, opts \\ []) when is_integer(count) and count > 0 do
    join = Options.get(opts, :join, false)

    words_list = Enum.map(1..count, fn _ -> word(opts) end)

    if join do
      Enum.join(words_list, " ")
    else
      words_list
    end
  end

  # Private functions

  @spec get_text_file(atom()) :: String.t()
  defp get_text_file(:lorem), do: Constants.lorem_ipsum_file()
  defp get_text_file(:meditations), do: Constants.meditations_file()

  @spec normalize_text(String.t()) :: String.t()
  defp normalize_text(text) do
    String.replace(text, Constants.new_line_regexp(), " ")
  end

  @spec extract_paragraph(String.t()) :: String.t()
  defp extract_paragraph(text) do
    text |> String.split("\n\n") |> Enum.shuffle() |> List.first()
  end

  @spec split_into_sentences(String.t()) :: [String.t()]
  defp split_into_sentences(text) do
    String.split(text, Constants.sentence_delimiter_regexp())
  end

  @spec remove_punctuation(String.t()) :: String.t()
  defp remove_punctuation(text) do
    String.replace(text, Constants.punctuation_regexp(), "")
  end

  @spec split_into_words(String.t()) :: [String.t()]
  defp split_into_words(text) do
    String.split(text)
  end

  @spec validate_text_source!(atom()) :: :ok
  defp validate_text_source!(source) when source in [:lorem, :meditations], do: :ok

  defp validate_text_source!(source) do
    raise ArgumentError,
          "Invalid text source. Expected one of #{inspect(Constants.valid_text_sources())}, got: #{inspect(source)}"
  end
end
