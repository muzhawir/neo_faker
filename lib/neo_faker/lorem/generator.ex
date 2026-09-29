defmodule NeoFaker.Lorem.Generator do
  @moduledoc false

  # Splits a source text into paragraphs and sentences once per locale and
  # source, via `NeoFaker.Data.derive!/5`, so each call only has to pick.

  alias NeoFaker.Data

  @files [lorem: "lorem_ipsum.exs", meditations: "meditations.exs"]

  # A single "\n" that is not part of a blank line: a mid-paragraph line wrap.
  @line_wrap ~r/(?<!\n)\n(?!\n)/
  @sentence_end ~r/(?<=[.!?])\s+/
  @punctuation ~r/[[:punct:]]/u

  @type source :: :lorem | :meditations

  @doc """
  Returns a random paragraph from `source`.
  """
  @spec paragraph(atom() | nil, source()) :: String.t()
  def paragraph(locale, source), do: locale |> paragraphs(source) |> Enum.random()

  @doc """
  Returns a random sentence from a random paragraph of `source`.
  """
  @spec sentence(atom() | nil, source()) :: String.t()
  def sentence(locale, source) do
    locale |> sentences_by_paragraph(source) |> Enum.random() |> Enum.random()
  end

  @doc """
  Returns a random lowercase word, without punctuation, from a random sentence of `source`.
  """
  @spec word(atom() | nil, source()) :: String.t()
  def word(locale, source) do
    locale
    |> sentence(source)
    |> String.replace(@punctuation, "")
    |> String.split()
    |> Enum.random()
    |> String.downcase()
  end

  defp paragraphs(locale, source) do
    Data.derive!(locale, NeoFaker.Lorem, file(source), :paragraphs, fn %{"text" => texts} ->
      Enum.flat_map(texts, &split_paragraphs/1)
    end)
  end

  defp sentences_by_paragraph(locale, source) do
    Data.derive!(locale, NeoFaker.Lorem, file(source), :sentences, fn %{"text" => texts} ->
      texts |> Enum.flat_map(&split_paragraphs/1) |> Enum.map(&split_non_blank(&1, @sentence_end))
    end)
  end

  @doc false
  # Joins wrapped lines, then splits on blank lines. Public for tests.
  @spec split_paragraphs(String.t()) :: [String.t()]
  def split_paragraphs(text) do
    text
    |> String.replace(@line_wrap, " ")
    |> split_non_blank("\n\n")
  end

  @doc false
  # Splits after `.`, `!`, or `?` followed by whitespace. Public for tests.
  @spec split_sentences(String.t()) :: [String.t()]
  def split_sentences(paragraph), do: split_non_blank(paragraph, @sentence_end)

  defp file(source), do: Keyword.fetch!(@files, source)

  # Blank fragments are dropped so that a trailing space or newline never
  # yields an empty paragraph or sentence for `Enum.random/1` to pick.
  defp split_non_blank(text, pattern) do
    text
    |> String.split(pattern)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
