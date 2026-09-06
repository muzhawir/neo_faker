defmodule NeoFaker.Color.KeywordGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @module NeoFaker.Color

  @doc """
  Returns a random keyword color string for the specified category and locale.

  If `category` is `:all`, selects a random color from all available keyword colors for the given
  locale. Otherwise, selects a random color from the specified category.
  """
  @spec color(:all | atom(), atom()) :: String.t()
  def color(:all, locale) do
    locale
    |> Data.fetch!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def color(category, locale) do
    Data.random_value(@module, "keyword.exs", Atom.to_string(category), locale: locale)
  end
end
