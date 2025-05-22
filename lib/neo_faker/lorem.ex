defmodule NeoFaker.Lorem do
  @moduledoc """
  Functions for generating random text using a Lorem Ipsum generator.

  This module provides utilities to generate random text, such as paragraphs, sentences, and
  words.
  """
  @moduledoc since: "0.8.0"

  import NeoFaker.Data.Generator, only: [random_value: 4]

  @new_line_regexp ~r/(?<!\n)\n(?!\n)/
  @punctuation_regexp ~r/[[:punct:]]/
  @sentence_delimiter_regexp ~r/(?<=[.!?])\s+/

  @doc """
  Generates a random paragraph.

  Returns a random Lorem Ipsum paragraph. If an option is provided, the paragraph is sourced from
  a specific text.

  ## Options

  The accepted options are:

  - `:text` - Specifies the text source.

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

  """
  @spec paragraph(Keyword.t()) :: String.t()
  def paragraph(opts \\ []) do
    file =
      case Keyword.get(opts, :text, :lorem) do
        :lorem -> "lorem_ipsum.exs"
        _ -> "meditations.exs"
      end

    __MODULE__
    |> random_value(file, "text", opts)
    |> String.replace(@new_line_regexp, " ")
    |> String.split("\n\n")
    |> Enum.shuffle()
    |> List.first()
  end

  @doc """
  Generates a random sentence.

  This function behaves the same way as `paragraph/1`. See `paragraph/1` for more details.
  """
  @spec sentence(Keyword.t()) :: String.t()
  def sentence(opts \\ []) do
    opts |> paragraph() |> String.split(@sentence_delimiter_regexp) |> Enum.random()
  end

  @doc """
  Generates a random word.

  This function behaves the same way as `paragraph/1`. See `paragraph/1` for more details.
  """
  @spec word(Keyword.t()) :: String.t()
  def word(opts \\ []) do
    opts
    |> sentence()
    |> String.replace(@punctuation_regexp, "")
    |> String.split()
    |> Enum.random()
    |> String.downcase()
  end
end
