defmodule NeoFaker.Lorem do
  @moduledoc """
  Functions for generating placeholder text.

  Text is drawn from one of two sources, selected with the `:text` option:

    * `:lorem` - the classic *Lorem ipsum* placeholder text.
    * `:meditations` - George Long's English translation of Marcus Aurelius'
      *Meditations*, for placeholder text that reads as real prose.

  The singular functions return a string. The plural functions return a list; use
  `Enum.join/2` if you need a single string.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Locale
  alias NeoFaker.Lorem.Generator

  @text_schema NimbleOptions.new!(
                 text: [type: {:in, [:lorem, :meditations]}, default: :lorem],
                 locale: [type: {:custom, Locale, :validate_option, []}, default: nil]
               )

  @doc """
  Generates a random paragraph.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Lorem.paragraph()
      "Suspendisse ac justo venenatis, tincidunt sapien nec, accumsan augue. Morbi ut blandit est."

      iex> NeoFaker.Lorem.paragraph(text: :meditations)
      "Do the things external which fall upon thee distract thee? Give thyself time to learn something new and good."

  """
  @spec paragraph(keyword()) :: String.t()
  def paragraph(opts \\ []) do
    {locale, source} = validate!(opts)
    Generator.paragraph(locale, source)
  end

  @doc """
  Generates a random sentence.

  The sentence is taken from a random paragraph, and keeps its closing punctuation.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Lorem.sentence()
      "Suspendisse ac justo venenatis, tincidunt sapien nec, accumsan augue."

      iex> NeoFaker.Lorem.sentence(text: :meditations)
      "Do the things external which fall upon thee distract thee?"

  """
  @spec sentence(keyword()) :: String.t()
  def sentence(opts \\ []) do
    {locale, source} = validate!(opts)
    Generator.sentence(locale, source)
  end

  @doc """
  Generates a random word.

  The word is lowercase and stripped of punctuation.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Lorem.word()
      "suspendisse"

      iex> NeoFaker.Lorem.word(text: :meditations)
      "distract"

  """
  @spec word(keyword()) :: String.t()
  def word(opts \\ []) do
    {locale, source} = validate!(opts)
    Generator.word(locale, source)
  end

  @doc """
  Generates multiple random paragraphs.

  `count` is the number of paragraphs and defaults to `3`. Raises `ArgumentError` if it is
  not a positive integer.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Lorem.paragraphs(2)
      ["Nulla facilisi. Quisque scelerisque lorem sed dui.", "Fusce nec aliquet elit, et euismod ex."]

  """
  @spec paragraphs(pos_integer(), keyword()) :: [String.t()]
  def paragraphs(count \\ 3, opts \\ []) do
    count = validate_count!(count)
    {locale, source} = validate!(opts)

    Enum.map(1..count, fn _ -> Generator.paragraph(locale, source) end)
  end

  @doc """
  Generates multiple random sentences.

  `count` is the number of sentences and defaults to `5`. Raises `ArgumentError` if it is
  not a positive integer.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Lorem.sentences(3)
      ["Nulla facilisi.", "Duis ac mi dolor.", "Aliquam erat volutpat."]

  """
  @spec sentences(pos_integer(), keyword()) :: [String.t()]
  def sentences(count \\ 5, opts \\ []) do
    count = validate_count!(count)
    {locale, source} = validate!(opts)

    Enum.map(1..count, fn _ -> Generator.sentence(locale, source) end)
  end

  @doc """
  Generates multiple random words.

  `count` is the number of words and defaults to `10`. Raises `ArgumentError` if it is
  not a positive integer.

  ## Options

    * `:text` (`:lorem` or `:meditations`) - the text source. Defaults to `:lorem`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Lorem.words(5)
      ["suspendisse", "justo", "venenatis", "sapien", "accumsan"]

  """
  @spec words(pos_integer(), keyword()) :: [String.t()]
  def words(count \\ 10, opts \\ []) do
    count = validate_count!(count)
    {locale, source} = validate!(opts)

    Enum.map(1..count, fn _ -> Generator.word(locale, source) end)
  end

  defp validate!(opts) do
    opts = NimbleOptions.validate!(opts, @text_schema)
    {Keyword.fetch!(opts, :locale), Keyword.fetch!(opts, :text)}
  end

  defp validate_count!(count) when is_integer(count) and count > 0, do: count

  defp validate_count!(count) do
    raise ArgumentError, "count must be a positive integer, got: #{inspect(count)}"
  end
end
