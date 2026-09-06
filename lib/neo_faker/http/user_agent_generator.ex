defmodule NeoFaker.HTTP.UserAgentGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @module NeoFaker.HTTP
  @user_agent_file "user_agent.exs"

  @type type :: :all | :browser | :crawler

  @doc """
  Generates a random user-agent string from all available user-agent data.

  Returns a randomly selected user-agent string, which may represent a browser or crawler.
  """
  @spec name(type()) :: String.t()
  def name(type) do
    case type do
      :all ->
        :default
        |> Data.fetch!(@module, @user_agent_file)
        |> Map.values()
        |> List.flatten()
        |> Enum.random()

      :browser ->
        Data.random_value(@module, @user_agent_file, "browsers")

      :crawler ->
        Data.random_value(@module, @user_agent_file, "crawlers")

      other ->
        raise ArgumentError,
              "Invalid user agent type: #{inspect(other)}. Expected :all, :browser, or :crawler."
    end
  end
end
