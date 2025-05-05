defmodule NeoFaker.Lorem.Utils do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]

  @module NeoFaker.Lorem
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/

  
  
  @doc """
  Returns a shuffled list of paragraphs from the specified lorem ipsum text source.
  
  Selects a text source and locale based on the provided options, retrieves the corresponding text, splits it into paragraphs, and returns the paragraphs in random order.
  """
  def lorem_ipsum(opts \\ []) do
    file = text_content(Keyword.get(opts, :text, :lorem))

    opts
    |> Keyword.get(:locale, :default)
    |> fetch_cache!(@module, file)
    |> Map.get("text")
    |> hd()
    |> String.replace(@new_line_regexp, " ")
    |> String.split("\n\n")
    |> Enum.shuffle()
  end

  defp text_content(:lorem), do: "lorem_ipsum.exs"
  defp text_content(:meditations), do: "meditations.exs"
end
