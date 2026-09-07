defmodule NeoFaker.HTTP.UserAgentGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @module NeoFaker.HTTP
  @user_agent_file "user_agent.exs"

  @type type :: :all | :browser | :crawler | :ai

  @doc """
  Returns a random user-agent for the given category.

  `:all` draws from every category combined; `:browser`, `:crawler`, and `:ai` draw from
  their own list.
  """
  @spec name(type()) :: String.t()
  def name(:all) do
    :default
    |> Data.fetch!(@module, @user_agent_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def name(:browser), do: Data.random_value(@module, @user_agent_file, "browsers")
  def name(:crawler), do: Data.random_value(@module, @user_agent_file, "crawlers")
  def name(:ai), do: Data.random_value(@module, @user_agent_file, "ai")
end
