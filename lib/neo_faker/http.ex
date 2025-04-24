defmodule NeoFaker.Http do
  @moduledoc """
  Functions for generating HTTP-related information.

  This module provides utilities to generate random internet-related information, such request
  methods, status codes, and user agents.
  """
  @moduledoc since: "0.10.0"

  import NeoFaker.Data.Generator, only: [random_data: 4]

  @user_agent_file "user_agent.exs"

  # import NeoFaker.Internet.Util

  @doc """
  Generates a random user agent.

  Returns a random user agent string.

  ## Examples

      iex> NeoFaker.Internet.user_agent()
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0"

  """
  def user_agent, do: random_data(__MODULE__, @user_agent_file, "user_agents", [])
end
