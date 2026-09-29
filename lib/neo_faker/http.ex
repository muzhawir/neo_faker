defmodule NeoFaker.HTTP do
  @moduledoc """
  Functions for generating HTTP protocol values.

  Covers request methods, status codes, header names, protocol versions, referrer
  policies, and user-agent strings. None of these values depend on the locale.
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

  @common_request_methods @request_methods -- ["HEAD", "OPTIONS", "TRACE", "CONNECT"]

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

  @protocol_versions ["HTTP/1.0", "HTTP/1.1", "HTTP/2", "HTTP/3"]

  @user_agent_types [:all, :browser, :crawler, :ai]
  @status_code_types [:simple, :detailed]
  @status_code_groups [:information, :success, :redirection, :client_error, :server_error]
  @header_name_types [:all, :request, :response]

  @user_agent_schema NimbleOptions.new!(type: [type: {:in, @user_agent_types}, default: :all])

  @request_method_schema NimbleOptions.new!(common_only: [type: :boolean, default: true])

  @status_code_schema NimbleOptions.new!(
                        type: [type: {:in, @status_code_types}, default: :simple],
                        group: [type: {:in, [nil | @status_code_groups]}, default: nil]
                      )

  @protocol_version_schema NimbleOptions.new!(include_http3: [type: :boolean, default: true])

  @header_name_schema NimbleOptions.new!(type: [type: {:in, @header_name_types}, default: :all])

  @doc """
  Generates a random HTTP header name.

  Draws from ten common request headers and ten common response headers.

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
  Generates a random HTTP protocol version string.

  Picks one of `"HTTP/1.0"`, `"HTTP/1.1"`, `"HTTP/2"`, and `"HTTP/3"`.

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

    if Keyword.fetch!(opts, :include_http3) do
      Enum.random(@protocol_versions)
    else
      Enum.random(@protocol_versions -- ["HTTP/3"])
    end
  end

  @doc """
  Generates a random HTTP referrer policy.

  Returns one of the eight values defined for the `Referrer-Policy` header.

  ## Examples

      iex> NeoFaker.HTTP.referrer_policy()
      "no-referrer"

      iex> NeoFaker.HTTP.referrer_policy()
      "strict-origin-when-cross-origin"

  """
  @spec referrer_policy() :: String.t()
  def referrer_policy, do: Enum.random(@referrer_policies)

  @doc """
  Returns every `Referrer-Policy` value that `referrer_policy/0` can generate.

  ## Examples

      iex> NeoFaker.HTTP.all_referrer_policies()
      ["no-referrer", "no-referrer-when-downgrade", "same-origin", "origin", "strict-origin",
       "origin-when-cross-origin", "strict-origin-when-cross-origin", "unsafe-url"]

  """
  @spec all_referrer_policies() :: [String.t()]
  def all_referrer_policies, do: @referrer_policies

  @doc """
  Generates a random HTTP request method.

  By default, returns one of the six methods common in application traffic: `GET`, `POST`,
  `PUT`, `DELETE`, `PATCH`, and `QUERY`.

  ## Options

    * `:common_only` (boolean) - when `false`, also includes `HEAD`, `OPTIONS`, `TRACE`,
      and `CONNECT`. Defaults to `true`.

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
        @common_request_methods
      else
        @request_methods
      end

    Enum.random(methods)
  end

  @doc """
  Returns every request method that `request_method/1` can generate.

  ## Examples

      iex> NeoFaker.HTTP.all_request_methods()
      ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE", "CONNECT", "QUERY"]

  """
  @spec all_request_methods() :: [String.t()]
  def all_request_methods, do: @request_methods

  @doc """
  Generates a random HTTP status code.

  Returns the code alone, such as `"404"`, or with its reason phrase, such as
  `"404 Not Found"`.

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

    StatusCodeGenerator.status_code(Keyword.fetch!(opts, :group), Keyword.fetch!(opts, :type))
  end

  @doc """
  Generates a random HTTP user-agent.

  Browser values are complete `User-Agent` header strings. Crawler and AI values are the
  bare product tokens that identify those bots, such as `"gptbot"` or `"ahrefsbot"`.

  ## Options

    * `:type` (`:all`, `:browser`, `:crawler`, or `:ai`) - the user-agent category. `:all` draws
      from every category. Defaults to `:all`.
      * `:browser` - a desktop or mobile browser.
      * `:crawler` - a search engine or SEO crawler.
      * `:ai` - an AI crawler or agent, such as `"gptbot"` or `"claude-user"`.

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
end
