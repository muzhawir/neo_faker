defmodule NeoFaker.Http.UserAgent do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Generator

  @module NeoFaker.Http
  @user_agent_file "user_agent.exs"

  @type type :: :all | :browser | :crawler

  @doc """
  Generates a random user-agent string from all available user-agent data.

  Returns a randomly user-agent string, which may represent a browser or crawler.
  """
  @spec generate(type()) :: String.t()
  def generate(:all) do
    :default
    |> Cache.fetch!(@module, @user_agent_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def generate(:browser), do: Generator.random_value(@module, @user_agent_file, "browsers")
  def generate(:crawler), do: Generator.random_value(@module, @user_agent_file, "crawlers")

  def generate(other) do
    raise ArgumentError,
          "Invalid user agent type: #{inspect(other)}. Expected :all, :browser, or :crawler."
  end
end
