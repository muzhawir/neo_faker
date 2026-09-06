defmodule NeoFaker.Lorem do
  @moduledoc """
  Functions for generating Lorem Ipsum text.

  Provides utilities to generate random paragraphs, sentences, and words sourced
  from either the classic Lorem Ipsum text or Marcus Aurelius' *Meditations*.
  All functions accept a `text:` option to switch between sources.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Data
  alias NeoFaker.Lorem.Generator

  @text_schema NimbleOptions.new!(
                 text: [type: {:in, [:lorem, :meditations]}, default: :lorem],
                 locale: [type: :atom, default: nil]
               )

  @join_schema NimbleOptions.new!(
                 join: [type: :boolean, default: false],
                 text: [type: {:in, [:lorem, :meditations]}, default: :lorem],
                 locale: [type: :atom, default: nil]
               )

  @doc """
  Generates a random paragraph.

  Returns a randomly selected paragraph from the chosen text source.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Lorem.paragraph()
      "Suspendisse ac justo venenatis, tincidunt sapien nec, accumsan augue. Vestibulum urna
      risus, egestas ut ultrices non, aliquet eget massa. Mauris id diam eget augue sagittis
      convallis sit amet nec diam. Morbi ut blandit est, et placerat neque."

      iex> NeoFaker.Lorem.paragraph(text: :meditations)
      "Do the things external which fall upon thee distract thee? Give thyself time to learn
      something new and good, and cease to be whirled around."

  """
  @spec paragraph(keyword()) :: String.t()
  def paragraph(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @text_schema)
    file = Generator.text_file(Keyword.fetch!(opts, :text))

    __MODULE__
    |> Data.random_value(file, "text", opts)
    |> Generator.normalize()
    |> Generator.extract_paragraph()
  end

  @doc """
  Generates a random sentence.

  Extracts a single sentence from a randomly chosen paragraph of the given text source.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Lorem.sentence()
      "Suspendisse ac justo venenatis, tincidunt sapien nec, accumsan augue."

      iex> NeoFaker.Lorem.sentence(text: :meditations)
      "Do the things external which fall upon thee distract thee?"

  """
  @spec sentence(keyword()) :: String.t()
  def sentence(opts \\ []) do
    opts |> paragraph() |> Generator.split_sentences() |> Enum.random()
  end

  @doc """
  Generates a random word.

  Extracts a single lowercase word from a randomly chosen sentence, stripped of punctuation.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Lorem.word()
      "suspendisse"

      iex> NeoFaker.Lorem.word(text: :meditations)
      "distract"

  """
  @spec word(keyword()) :: String.t()
  def word(opts \\ []) do
    opts
    |> sentence()
    |> Generator.remove_punctuation()
    |> Generator.split_words()
    |> Enum.random()
    |> String.downcase()
  end

  @doc """
  Generates multiple random paragraphs.

  Returns a list of paragraphs. `count` sets how many are generated and defaults to `3`.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.
    * `:join` (boolean) - when `true`, joins the paragraphs with `"\\n\\n"` into a single
      string instead of returning a list. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Lorem.paragraphs(2)
      ["First paragraph...", "Second paragraph..."]

      iex> NeoFaker.Lorem.paragraphs(2, join: true)
      "First paragraph...\\n\\nSecond paragraph..."

  """
  @spec paragraphs(pos_integer(), keyword()) :: [String.t()] | String.t()
  def paragraphs(count \\ 3, opts \\ []) when is_integer(count) and count > 0 do
    opts = NimbleOptions.validate!(opts, @join_schema)
    text_opts = Keyword.take(opts, [:text, :locale])

    paragraphs_list = Enum.map(1..count, fn _ -> paragraph(text_opts) end)

    if Keyword.fetch!(opts, :join) do
      Enum.join(paragraphs_list, "\n\n")
    else
      paragraphs_list
    end
  end

  @doc """
  Generates multiple random sentences.

  Returns a list of sentences. `count` sets how many are generated and defaults to `5`.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.
    * `:join` (boolean) - when `true`, joins the sentences with `" "` into a single string
      instead of returning a list. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Lorem.sentences(3)
      ["First sentence.", "Second sentence.", "Third sentence."]

      iex> NeoFaker.Lorem.sentences(3, join: true)
      "First sentence. Second sentence. Third sentence."

  """
  @spec sentences(pos_integer(), keyword()) :: [String.t()] | String.t()
  def sentences(count \\ 5, opts \\ []) when is_integer(count) and count > 0 do
    opts = NimbleOptions.validate!(opts, @join_schema)
    text_opts = Keyword.take(opts, [:text, :locale])

    sentences_list = Enum.map(1..count, fn _ -> sentence(text_opts) end)

    if Keyword.fetch!(opts, :join) do
      Enum.join(sentences_list, " ")
    else
      sentences_list
    end
  end

  @doc """
  Generates multiple random words.

  Returns a list of words. `count` sets how many are generated and defaults to `10`.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.
    * `:join` (boolean) - when `true`, joins the words with `" "` into a single string
      instead of returning a list. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Lorem.words(5)
      ["suspendisse", "justo", "venenatis", "sapien", "accumsan"]

      iex> NeoFaker.Lorem.words(5, join: true)
      "suspendisse justo venenatis sapien accumsan"

  """
  @spec words(pos_integer(), keyword()) :: [String.t()] | String.t()
  def words(count \\ 10, opts \\ []) when is_integer(count) and count > 0 do
    opts = NimbleOptions.validate!(opts, @join_schema)
    text_opts = Keyword.take(opts, [:text, :locale])

    words_list = Enum.map(1..count, fn _ -> word(text_opts) end)

    if Keyword.fetch!(opts, :join) do
      Enum.join(words_list, " ")
    else
      words_list
    end
  end
end
