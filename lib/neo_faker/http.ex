defmodule NeoFaker.HTTP do
  @moduledoc """
  Functions for generating HTTP-related data.

  Provides utilities to generate random HTTP values including user-agent strings, request
  methods, status codes, referrer policies, protocol versions, and header names.
  """
  @moduledoc since: "0.11.0"

  alias NeoFaker.HTTP.HeaderGenerator
  alias NeoFaker.HTTP.StatusCodeGenerator
  alias NeoFaker.HTTP.UserAgentGenerator

  @request_methods [
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
    "TRACE",
    "CONNECT",
    "QUERY"
  ]

  @referrer_policies [
    "no-referrer",
    "no-referrer-when-downgrade",
    "same-origin",
    "origin",
    "strict-origin",
    "origin-when-cross-origin",
    "strict-origin-when-cross-origin",
    "unsafe-url"
  ]

  @user_agent_schema NimbleOptions.new!(
                       type: [type: {:in, [:all, :browser, :crawler, :ai]}, default: :all]
                     )

  @request_method_schema NimbleOptions.new!(common_only: [type: :boolean, default: true])

  @status_code_schema NimbleOptions.new!(
                        type: [type: {:in, [:simple, :detailed]}, default: :simple],
                        group: [
                          type:
                            {:or,
                             [
                               nil,
                               {:in,
                                [
                                  :information,
                                  :success,
                                  :redirection,
                                  :client_error,
                                  :server_error
                                ]}
                             ]},
                          default: nil
                        ]
                      )

  @protocol_version_schema NimbleOptions.new!(include_http3: [type: :boolean, default: true])

  @header_name_schema NimbleOptions.new!(
                        type: [type: {:in, [:all, :request, :response]}, default: :all]
                      )

  @doc """
  Generates a random HTTP user-agent.

  Browsers are full user-agent strings; crawlers and AI agents are the bare bot tokens
  (`"gptbot"`, `"ahrefsbot"`) that identify them in a `User-Agent` header.

  ## Options

    * `:type` (`:all`, `:browser`, `:crawler`, or `:ai`) - the user-agent category. `:all` draws
      from every category. Defaults to `:all`.
      * `:browser` - a real browser user-agent string.
      * `:crawler` - a search/SEO crawler bot token.
      * `:ai` - an AI crawler or agent bot token (`"gptbot"`, `"claudebot"`, `"perplexitybot"`).

  ## Examples

      iex> NeoFaker.HTTP.user_agent()
      "Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.HTTP.user_agent(type: :browser)
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.HTTP.user_agent(type: :crawler)
      "ahrefsbot"

      iex> NeoFaker.HTTP.user_agent(type: :ai)
      "claude-user"

  """
  @spec user_agent(keyword()) :: String.t()
  def user_agent(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @user_agent_schema)
    UserAgentGenerator.name(Keyword.fetch!(opts, :type))
  end

  @doc """
  Generates a random HTTP request method.

  Returns one of the common methods (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `QUERY`) by default.

  ## Options

    * `:common_only` (boolean) - when `false`, includes all ten standard methods instead of just
      the six most common. Defaults to `true`.

  ## Examples

      iex> NeoFaker.HTTP.request_method()
      "GET"

      iex> NeoFaker.HTTP.request_method(common_only: false)
      "OPTIONS"

  """
  @spec request_method(keyword()) :: String.t()
  def request_method(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @request_method_schema)

    methods =
      if Keyword.fetch!(opts, :common_only) do
        @request_methods -- ["HEAD", "OPTIONS", "TRACE", "CONNECT"]
      else
        @request_methods
      end

    Enum.random(methods)
  end

  @doc """
  Generates a random HTTP referrer policy.

  Returns one of the eight standard `Referrer-Policy` header values.

  ## Examples

      iex> NeoFaker.HTTP.referrer_policy()
      "no-referrer"

      iex> NeoFaker.HTTP.referrer_policy()
      "strict-origin-when-cross-origin"

  """
  @spec referrer_policy() :: String.t()
  def referrer_policy, do: Enum.random(@referrer_policies)

  @doc """
  Generates a random HTTP status code.

  Returns either a simple code string (e.g. `"200"`) or a detailed one (e.g. `"200 OK"`).

  ## Options

    * `:type` (`:simple` or `:detailed`) - `:simple` returns the code only; `:detailed`
      includes the reason phrase. Defaults to `:simple`.
    * `:group` (an atom below, or `nil`) - restricts sampling to one status code group.
      Defaults to `nil` (all groups).
      * `:information` - 1xx Informational.
      * `:success` - 2xx Success.
      * `:redirection` - 3xx Redirection.
      * `:client_error` - 4xx Client Error.
      * `:server_error` - 5xx Server Error.

  ## Examples

      iex> NeoFaker.HTTP.status_code()
      "200"

      iex> NeoFaker.HTTP.status_code(type: :detailed)
      "200 OK"

      iex> NeoFaker.HTTP.status_code(group: :client_error)
      "404"

      iex> NeoFaker.HTTP.status_code(type: :detailed, group: :success)
      "201 Created"

  """
  @spec status_code(keyword()) :: String.t()
  def status_code(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @status_code_schema)

    opts
    |> Keyword.fetch!(:group)
    |> StatusCodeGenerator.generates!()
    |> StatusCodeGenerator.number(type: Keyword.fetch!(opts, :type))
  end

  @doc """
  Generates a random HTTP protocol version string.

  Randomly selects from `HTTP/1.0`, `HTTP/1.1`, `HTTP/2`, and optionally `HTTP/3`.

  ## Options

    * `:include_http3` (boolean) - when `false`, excludes `HTTP/3` from the pool. Defaults
      to `true`.

  ## Examples

      iex> NeoFaker.HTTP.protocol_version()
      "HTTP/1.1"

      iex> NeoFaker.HTTP.protocol_version(include_http3: false)
      "HTTP/1.0"

  """
  @spec protocol_version(keyword()) :: String.t()
  def protocol_version(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @protocol_version_schema)

    versions = ["HTTP/1.0", "HTTP/1.1", "HTTP/2"]

    versions =
      if Keyword.fetch!(opts, :include_http3) do
        versions ++ ["HTTP/3"]
      else
        versions
      end

    Enum.random(versions)
  end

  @doc """
  Generates a random HTTP header name.

  Returns a common request or response header name from a curated list of ten per category.

  ## Options

    * `:type` (`:all`, `:request`, or `:response`) - the header category. `:request` returns
      headers such as `"User-Agent"`; `:response` returns headers such as `"Server"`. Defaults
      to `:all` (both categories combined).

  ## Examples

      iex> NeoFaker.HTTP.header_name()
      "Content-Type"

      iex> NeoFaker.HTTP.header_name(type: :request)
      "User-Agent"

      iex> NeoFaker.HTTP.header_name(type: :response)
      "Server"

  """
  @spec header_name(keyword()) :: String.t()
  def header_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @header_name_schema)
    HeaderGenerator.name(Keyword.fetch!(opts, :type))
  end

  @doc """
  Returns the list of all valid HTTP request methods.

  ## Examples

      iex> NeoFaker.HTTP.all_request_methods()
      ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE", "CONNECT", "QUERY"]

  """
  @spec all_request_methods() :: [String.t()]
  def all_request_methods, do: @request_methods

  @doc """
  Returns the list of all valid referrer policy strings.

  ## Examples

      iex> NeoFaker.HTTP.all_referrer_policies()
      ["no-referrer", "no-referrer-when-downgrade", ...]

  """
  @spec all_referrer_policies() :: [String.t()]
  def all_referrer_policies, do: @referrer_policies
end
