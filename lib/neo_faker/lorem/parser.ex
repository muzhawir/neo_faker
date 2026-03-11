defmodule NeoFaker.Lorem.Parser do
  @moduledoc false

  @lorem_ipsum_file "lorem_ipsum.exs"
  @meditations_file "meditations.exs"
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/
  @punctuation_regexp ~r/[[:punct:]]/
  @sentence_delimiter_regexp ~r/(?<=[.!?])\s+/

  @spec text_file(atom()) :: String.t()
  def text_file(:lorem), do: @lorem_ipsum_file
  def text_file(:meditations), do: @meditations_file

  @spec normalize(String.t()) :: String.t()
  def normalize(text), do: String.replace(text, @new_line_regexp, " ")

  @spec extract_paragraph(String.t()) :: String.t()
  def extract_paragraph(text) do
    text |> String.split("\n\n") |> Enum.shuffle() |> List.first()
  end

  @spec split_sentences(String.t()) :: [String.t()]
  def split_sentences(text), do: String.split(text, @sentence_delimiter_regexp)

  @spec remove_punctuation(String.t()) :: String.t()
  def remove_punctuation(text), do: String.replace(text, @punctuation_regexp, "")

  @spec split_words(String.t()) :: [String.t()]
  def split_words(text), do: String.split(text)
end
