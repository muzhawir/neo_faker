defmodule NeoFaker.Lorem.Utils do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]

  @module NeoFaker.Lorem
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/

  @doc """
  Returns a list of paragraphs from a text source.

  Fetches the paragraphs from the specified text source and returns a list of paragraphs.
  """
  @spec lorem_ipsum(keyword()) :: list()
  def lorem_ipsum(opts \\ []) do
    locale = Keyword.get(opts, :locale, :default)
    file = opts |> Keyword.get(:text) |> text_content()

    locale
    |> fetch_cache!(@module, file)
    |> Map.get("text")
    |> hd()
    |> String.replace(@new_line_regexp, " ")
    |> String.split("\n\n")
    |> Enum.shuffle()
  end

  defp text_content(nil), do: "lorem_ipsum.exs"
  defp text_content(:meditations), do: "meditations.exs"
end
