defmodule NeoFaker.Lorem.Parser do
  @moduledoc false

  @lorem_ipsum_file "lorem_ipsum.exs"
  @meditations_file "meditations.exs"
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/
  @punctuation_regexp ~r/[[:punct:]]/
  @sentence_delimiter_regexp ~r/(?<=[.!?])\s+/

  @doc """
  Returns the data file name for the given text source.

  Accepts `:lorem` or `:meditations` and returns the corresponding filename string.
  """
  @spec text_file(atom()) :: String.t()
  def text_file(:lorem), do: @lorem_ipsum_file
  def text_file(:meditations), do: @meditations_file

  @doc """
  Normalizes a text string by replacing single newlines with spaces.

  Double newlines (paragraph separators) are left intact.
  """
  @spec normalize(String.t()) :: String.t()
  def normalize(text), do: String.replace(text, @new_line_regexp, " ")

  @doc """
  Extracts a random paragraph from the given text.

  Splits the text on double newlines, shuffles the resulting paragraphs, and returns the first
  one.
  """
  @spec extract_paragraph(String.t()) :: String.t()
  def extract_paragraph(text) do
    text |> String.split("\n\n") |> Enum.shuffle() |> List.first()
  end

  @doc """
  Splits a text string into a list of sentences.

  Sentences are delimited by `.`, `!`, or `?` followed by whitespace.
  """
  @spec split_sentences(String.t()) :: [String.t()]
  def split_sentences(text), do: String.split(text, @sentence_delimiter_regexp)

  @doc """
  Removes all punctuation characters from the given text string.
  """
  @spec remove_punctuation(String.t()) :: String.t()
  def remove_punctuation(text), do: String.replace(text, @punctuation_regexp, "")

  @doc """
  Splits a text string into a list of words on whitespace boundaries.
  """
  @spec split_words(String.t()) :: [String.t()]
  def split_words(text), do: String.split(text)
end
