defmodule NeoFaker.Http.UserAgent do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 3]

  @module NeoFaker.Http
  @user_agent_file "user_agent.exs"

  
  
  @doc """
  Generates a random user-agent string from all available user-agent data.
  
  Returns a randomly selected user-agent string, which may represent a browser or crawler.
  """
  def generate_user_agent(:all) do
    :default
    |> fetch_cache!(@module, @user_agent_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  @doc """
Returns a random browser user-agent string.
"""
@spec generate_user_agent(:browser) :: String.t()
def generate_user_agent(:browser), do: random_data(@module, @user_agent_file, "browsers")

  @doc """
Returns a random crawler user-agent string.
"""
@spec generate_user_agent(:crawler) :: String.t()
def generate_user_agent(:crawler), do: random_data(@module, @user_agent_file, "user_agents")
end
