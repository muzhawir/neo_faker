defmodule NeoFaker.Lorem.Generator do
  @moduledoc false

  # Text-manipulation helpers shared by NeoFaker.Lorem's paragraph/sentence/word
  # functions, regardless of which source text (:lorem or :meditations) they
  # were told to draw from via the :text option.

  @lorem_ipsum_file "lorem_ipsum.exs"
  @meditations_file "meditations.exs"
  # Matches a single "\n" not adjacent to another "\n", so paragraph breaks
  # ("\n\n") are left untouched while mid-paragraph line wraps collapse to a space.
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/
  @punctuation_regexp ~r/[[:punct:]]/
  @sentence_delimiter_regexp ~r/(?<=[.!?])\s+/

  @spec text_file(atom()) :: String.t()
  def text_file(:lorem), do: @lorem_ipsum_file
  def text_file(:meditations), do: @meditations_file

  @doc """
  Collapses mid-paragraph line wraps to spaces, leaving blank-line paragraph
  separators intact so `extract_paragraph/1` can still split on them.
  """
  @spec normalize(String.t()) :: String.t()
  def normalize(text), do: String.replace(text, @new_line_regexp, " ")

  @spec extract_paragraph(String.t()) :: String.t()
  def extract_paragraph(text) do
    text |> String.split("\n\n") |> Enum.random()
  end

  @doc """
  Splits on `.`, `!`, or `?` followed by whitespace, keeping the delimiter
  attached to the sentence it ends.
  """
  @spec split_sentences(String.t()) :: [String.t()]
  def split_sentences(text), do: String.split(text, @sentence_delimiter_regexp)

  @spec remove_punctuation(String.t()) :: String.t()
  def remove_punctuation(text), do: String.replace(text, @punctuation_regexp, "")

  @spec split_words(String.t()) :: [String.t()]
  def split_words(text), do: String.split(text)
end
