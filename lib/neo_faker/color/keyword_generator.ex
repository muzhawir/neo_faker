defmodule NeoFaker.Color.KeywordGenerator do
  @moduledoc false

  alias NeoFaker.Data

  # NeoFaker.Data derives the data subdirectory from this module name (its
  # downcased last segment), so this must point at the domain module
  # (resolves to "color/") rather than __MODULE__, which would resolve to
  # the wrong directory ("keyword_generator/").
  @module NeoFaker.Color

  @doc """
  Returns a random keyword color string for the given category and locale.

  `:all` draws from every category's colors combined; any other category atom draws only from
  that category's own list.
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
