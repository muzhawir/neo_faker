defmodule NeoFaker.Http do
  @moduledoc """
  Functions for generating HTTP-related information.

  This module provides utilities to generate random internet-related information, such request
  methods, status codes, and user-agents.
  """
  @moduledoc since: "0.11.0"

  alias NeoFaker.Http.StatusCode
  alias NeoFaker.Http.UserAgent

  @doc """
  Generates a random HTTP user-agent string.

  Returns a random user-agent string representing either a browser or a crawler from the top
  100 most common user-agents.

  ## Options

  The accepted options are:

  - `:type` - Defines the type of user-agent to generate.

  The values for `:type` can be:

  - `:all` - Returns a random user-agent from both browsers and crawlers (default).
  - `:browser` - Returns a random browser user-agent.
  - `:crawler` - Returns a random crawler user-agent.

  ## Examples

      iex> NeoFaker.Internet.user_agent()
      "Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.Internet.user_agent(type: :browser)
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.Internet.user_agent(type: :crawler)
      "Mozilla/5.0 (compatible; Google-InspectionTool/1.0)"

  """
  @spec user_agent(Keyword.t()) :: String.t()
  def user_agent(opts \\ []), do: UserAgent.generate(Keyword.get(opts, :type, :all))

  @doc """
  Generates a random HTTP request method.

  Returns a random HTTP request method string (e.g., `"GET"`, `"POST"`, `"PUT"`, `"DELETE"`, or
  `"PATCH"`).

  ## Examples

      iex> NeoFaker.Http.request_method()
      "GET"

  """
  @spec request_method() :: String.t()
  def request_method, do: Enum.random(["GET", "POST", "PUT", "DELETE", "PATCH"])

  @doc """
  Generates a random HTTP referrer policy.

  Returns a random HTTP referrer policy string (e.g., `"no-referrer"`, `"same-origin"`,
  `"strict-origin-when-cross-origin"`).

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
  Generates a random HTTP status code string.

  Returns a random HTTP status code string, which can be either detailed (e.g., `"200 OK"`) or
  simple (e.g., `"200"`).

  ## Options

  The accepted options are:

  - `:type` - Defines the type of status code to generate.
  - `:group` - Specifies the group of status codes to generate.

  The values for `:type` can be:

  - `:detailed` - Returns a detailed status code (e.g., `"200 OK"`), which is the default.
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
  @spec status_code(Keyword.t()) :: String.t()
  def status_code(opts \\ []) do
    type = Keyword.get(opts, :type, :detailed)
    status_codes = StatusCode.fetch!(Keyword.get(opts, :group))

    StatusCode.generate(status_codes, type: type)
  end
end
