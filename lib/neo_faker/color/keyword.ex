defmodule NeoFaker.Color.Keyword do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_value: 4]

  alias NeoFaker.Data.Cache

  @module NeoFaker.Color

  @doc """
  Returns a random keyword color string for the specified locale and optional category.

  If `category` is `:all`, selects a random color from all available keyword colors for the given
  locale.
  """
  def color(:all, locale) do
    locale
    |> Cache.fetch!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def color(category, locale) do
    random_value(@module, "keyword.exs", Atom.to_string(category), locale: locale)
  end
end
