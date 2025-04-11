defmodule NeoFaker.Lorem.Utils do
  @moduledoc false

  import NeoFaker.Helper.Generator, only: [fetch_data: 3]

  alias NeoFaker.Helper.Locale

  @module NeoFaker.Lorem
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/

  @doc """
  Returns a list of paragraphs from a text source.

  Fetches the paragraphs from the specified text source and returns a list of paragraphs.
  """
  @spec lorem_ipsum(keyword()) :: list()
  def lorem_ipsum(opts \\ []) do
    content = opts |> Keyword.get(:type) |> text_content()
    locale = opts |> Keyword.get(:locale, nil) |> Locale.locale_path()

    @module
    |> fetch_data(content, locale: locale)
    |> Map.get("text")
    |> hd()
    |> String.replace(@new_line_regexp, " ")
    |> String.split("\n\n")
    |> Enum.shuffle()
  end

  defp text_content(nil), do: "lorem_ipsum.exs"
  defp text_content(:meditations), do: "meditations.exs"
end
