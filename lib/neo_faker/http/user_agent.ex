defmodule NeoFaker.Http.UserAgent do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_value: 3]

  alias NeoFaker.Data.Cache

  @module NeoFaker.Http
  @user_agent_file "user_agent.exs"

  @type user_agent_type :: :all | :browser | :crawler

  @doc """
  Generates a random user-agent string from all available user-agent data.

  Returns a randomly user-agent string, which may represent a browser or crawler.
  """
  @spec generate_user_agent(user_agent_type()) :: String.t()
  def generate_user_agent(:all) do
    :default
    |> Cache.fetch!(@module, @user_agent_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def generate_user_agent(:browser), do: random_value(@module, @user_agent_file, "browsers")
  def generate_user_agent(:crawler), do: random_value(@module, @user_agent_file, "crawlers")

  def generate_user_agent(other) do
    raise ArgumentError,
          "Invalid user agent type: #{inspect(other)}. Expected :all, :browser, or :crawler."
  end
end
