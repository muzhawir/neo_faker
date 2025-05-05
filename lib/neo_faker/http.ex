defmodule NeoFaker.Http do
  @moduledoc """
  Functions for generating HTTP-related information.

  This module provides utilities to generate random internet-related information, such request
  methods, status codes, and user-agents.
  """
  @moduledoc since: "0.11.0"

  import NeoFaker.Http.StatusCode
  import NeoFaker.Http.UserAgent

  
  
  @doc """
Generates a random HTTP user-agent string.

Selects a user-agent from a curated list of the top 100 most common HTTP user-agents, with optional filtering by type (`:all`, `:browser`, or `:crawler`). The default is `:all`.

## Examples

    iex> NeoFaker.Http.user_agent()
    "Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

    iex> NeoFaker.Http.user_agent(type: :browser)
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

    iex> NeoFaker.Http.user_agent(type: :crawler)
    "Mozilla/5.0 (compatible; Google-InspectionTool/1.0)"
"""
@spec user_agent(Keyword.t()) :: String.t()
def user_agent(opts \\ []), do: generate_user_agent(Keyword.get(opts, :type, :all))

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
  Generates a random HTTP status code string, optionally filtered by type or status code group.
  
  By default, returns a detailed status code (e.g., `"200 OK"`). You can specify the format (`:detailed` or `:simple`) and restrict the selection to a specific status code group (such as informational, success, redirection, client error, or server error).
  
  ## Options
  
    - `:type` (`:detailed` | `:simple`) – Format of the status code string. Defaults to `:detailed`.
    - `:group` (`:information` | `:success` | `:redirection` | `:client_error` | `:server_error` | `nil`) – Restricts the selection to a specific group of status codes. Defaults to `nil` (all codes).
  
  ## Examples
  
      iex> NeoFaker.Http.status_code()
      "200 OK"
  
      iex> NeoFaker.Http.status_code(type: :simple)
      "200"
  
      iex> NeoFaker.Http.status_code(group: :client_error)
      "404 Not Found"
  """
  def status_code(opts \\ []) do
    type = Keyword.get(opts, :type, :detailed)
    status_codes = fetch_status_codes!(Keyword.get(opts, :group))

    generate_status_code(status_codes, type: type)
  end
end
