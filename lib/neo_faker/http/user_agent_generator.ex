defmodule NeoFaker.HTTP.UserAgentGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @categories [browser: "browsers", crawler: "crawlers", ai: "ai"]

  @type type :: :all | :browser | :crawler | :ai

  @doc """
  Returns a random user-agent from the given category, or from every category for `:all`.
  """
  @spec name(type()) :: String.t()
  def name(type) do
    keys =
      case type do
        :all -> Keyword.values(@categories)
        category -> Keyword.fetch!(@categories, category)
      end

    Data.random_value(NeoFaker.HTTP, "user_agent.exs", keys, locale: :default)
  end
end
