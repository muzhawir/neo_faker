defmodule NeoFaker.Http do
  @moduledoc """
  Functions for generating HTTP-related information.

  This module provides utilities to generate random internet-related information, such request
  methods, status codes, and user-agents.
  """
  @moduledoc since: "0.11.0"

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 3]

  @user_agent_file "user_agent.exs"

  # import NeoFaker.Internet.Util

  @doc """
  Generates a random user-agent.

  Returns a random user-agent string from the top 100 HTTP user-agents most used over the Internet
  by [https://microlink.io/user-agents](https://microlink.io/user-agents).

  ## Examples

      iex> NeoFaker.Internet.user_agent()
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0"

  """
  def user_agent, do: random_data(__MODULE__, @user_agent_file, "user_agents")

  @doc """
  Generates a random HTTP request method.

  Returns a random HTTP request method string.

  ## Examples

      iex> NeoFaker.Http.request_method()
      "GET"

  """
  @spec request_method() :: String.t()
  def request_method, do: Enum.random(["GET", "POST", "PUT", "DELETE", "PATCH"])

  @doc """
  Generates a random HTTP referrer policy.

  Returns a random HTTP referrer policy string.

  ## Examples

      iex> NeoFaker.Http.referrer_policy()
      "no-referrer"

  """
  @spec referrer_policy() :: String.t()
  def referrer_policy do
    Enum.random([
      "no-referrer",
      "no-referrer-when-downgrade",
      "same-origin",
      "origin",
      "strict-origin",
      "origin-when-cross-origin",
      "strict-origin-when-cross-origin",
      "unsafe-url"
    ])
  end

  @doc """
  Generates a random HTTP status code.

  Returns a random HTTP status code string. If no options are provided, it will return a detailed
  status code.

  ## Options

  The accepted options are:

  - `:type` - Defines the type of status code to generate.
  - `:group` - Specifies the group of status codes to generate.

  The values for `:type` can be:

  - `:detailed` - Returns a detailed status code (default).
  - `:simple` - Returns a simple status code (e.g., `"200"` instead of `"200 OK"`).

  The values for `:group` can be:

  - `nil` - All status codes (default).
  - `:information` - 1xx status codes (Informational).
  - `:success` - 2xx status codes (Success).
  - `:redirection` - 3xx status codes (Redirection).
  - `:client_error` - 4xx status codes (Client Error).
  - `:server_error` - 5xx status codes (Server Error).

  ## Examples

      iex> NeoFaker.Http.status_code()
      "200 OK"

      iex> NeoFaker.Http.status_code(type: :simple)
      "200"

      iex> NeoFaker.Http.status_code(group: :client_error)
      "404 Not Found"

  """
  @spec status_code(opts :: Keyword.t()) :: String.t()
  def status_code(opts \\ []) do
    type = Keyword.get(opts, :type, :detailed)
    status_codes = fetch_status_code_values!(Keyword.get(opts, :group))

    generate_status_code(status_codes, type: type)
  end

  defp fetch_status_code_values!(nil) do
    :default
    |> fetch_cache!(NeoFaker.Http, "status_code.exs")
    |> Map.values()
    |> List.flatten()
  end

  defp fetch_status_code_values!(group) do
    :default
    |> fetch_cache!(NeoFaker.Http, "status_code.exs")
    |> Map.get(Atom.to_string(group))
  end

  defp generate_status_code(status_codes, type: :detailed), do: Enum.random(status_codes)

  defp generate_status_code(status_codes, type: :simple) do
    get_status_number = fn code -> code |> String.split(" ", parts: 2) |> List.first() end

    status_codes |> Enum.map(&get_status_number.(&1)) |> Enum.random()
  end
end
