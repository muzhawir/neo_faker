defmodule NeoFaker.Http.UserAgent do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Generator

  @module NeoFaker.Http
  @user_agent_file "user_agent.exs"

  @type type :: :all | :browser | :crawler

  @doc """
  Generates a random user-agent string from all available user-agent data.

  Returns a randomly selected user-agent string, which may represent a browser or crawler.
  """
  @spec generate(type()) :: String.t()
  def generate(type) do
    case type do
      :all ->
        :default
        |> Cache.fetch!(@module, @user_agent_file)
        |> Map.values()
        |> List.flatten()
        |> Enum.random()

      :browser ->
        Generator.random_value(@module, @user_agent_file, "browsers")

      :crawler ->
        Generator.random_value(@module, @user_agent_file, "crawlers")

      other ->
        raise ArgumentError,
              "Invalid user agent type: #{inspect(other)}. Expected :all, :browser, or :crawler."
    end
  end
end
