defmodule NeoFaker.HTTP do
  @moduledoc """
  Functions for generating HTTP-related information.

  This module provides utilities to generate random HTTP-related information, such as request
  methods, status codes, user-agents, and referrer policies with comprehensive validation
  and formatting options.
  """
  @moduledoc since: "0.11.0"

  alias NeoFaker.Helpers.Options
  alias NeoFaker.HTTP.StatusCode
  alias NeoFaker.HTTP.UserAgent

  @valid_user_agent_types [:all, :browser, :crawler]
  @valid_request_methods [
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
    "TRACE",
    "CONNECT"
  ]

  @valid_referrer_policies [
    "no-referrer",
    "no-referrer-when-downgrade",
    "same-origin",
    "origin",
    "strict-origin",
    "origin-when-cross-origin",
    "strict-origin-when-cross-origin",
    "unsafe-url"
  ]

  @valid_status_code_types [:detailed, :simple]
  @valid_status_code_groups [:information, :success, :redirection, :client_error, :server_error]

  @doc """
  Generates a random HTTP user-agent string.

  Returns a random user-agent string representing either a browser or a crawler from the top
  100 most common user-agents.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Defines the type of user-agent to generate. Defaults to `:all`.

  ## Options

  The values for `:type` can be:

  - `:all` - Returns a random user-agent from both browsers and crawlers (default).
  - `:browser` - Returns a random browser user-agent.
  - `:crawler` - Returns a random crawler user-agent.

  ## Examples

      iex> NeoFaker.HTTP.user_agent()
      "Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.HTTP.user_agent(type: :browser)
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.HTTP.user_agent(type: :crawler)
      "Mozilla/5.0 (compatible; Google-InspectionTool/1.0)"

      iex> NeoFaker.HTTP.user_agent(type: :all)
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

  """
  @spec user_agent(Keyword.t()) :: String.t()
  def user_agent(opts \\ []) do
    type = Options.get(opts, :type, :all)
    validate_user_agent_type!(type)
    UserAgent.name(type)
  end

  @doc """
  Generates a random HTTP request method.

  Returns a random HTTP request method string. By default, returns one of the most common
  methods (GET, POST, PUT, DELETE, PATCH).

  ## Parameters

  - `opts` - Keyword list of options:
    - `:common_only` - When `true`, only returns common methods. Defaults to `true`.

  ## Examples

      iex> NeoFaker.HTTP.request_method()
      "GET"

      iex> NeoFaker.HTTP.request_method()
      "POST"

      iex> NeoFaker.HTTP.request_method(common_only: false)
      "OPTIONS"

      iex> NeoFaker.HTTP.request_method(common_only: true)
      "PUT"

  """
  @spec request_method(Keyword.t()) :: String.t()
  def request_method(opts \\ []) do
    common_only = Options.get(opts, :common_only, true)

    methods =
      if common_only do
        ["GET", "POST", "PUT", "DELETE", "PATCH"]
      else
        @valid_request_methods
      end

    Enum.random(methods)
  end

  @doc """
  Generates a random HTTP referrer policy.

  Returns a random HTTP referrer policy string that controls how much referrer information
  should be included with requests.

  ## Examples

      iex> NeoFaker.HTTP.referrer_policy()
      "no-referrer"

      iex> NeoFaker.HTTP.referrer_policy()
      "strict-origin-when-cross-origin"

      iex> NeoFaker.HTTP.referrer_policy()
      "same-origin"

  """
  @spec referrer_policy() :: String.t()
  def referrer_policy, do: Enum.random(@valid_referrer_policies)

  @doc """
  Generates a random HTTP status code.

  Returns a random HTTP status code, which can be either detailed (e.g., `"200 OK"`) or
  simple (e.g., `"200"`). Optionally filter by status code group.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Defines the type of status code to generate. Defaults to `:simple`.
    - `:group` - Specifies the group of status codes to generate. Defaults to `nil` (all).

  ## Options

  The values for `:type` can be:

  - `:simple` - Returns a simple status code (e.g., `"200"`) (default).
  - `:detailed` - Returns a detailed status code (e.g., `"200 OK"`).

  The values for `:group` can be:

  - `nil` - All status codes (default).
  - `:information` - 1xx status codes (Informational).
  - `:success` - 2xx status codes (Success).
  - `:redirection` - 3xx status codes (Redirection).
  - `:client_error` - 4xx status codes (Client Error).
  - `:server_error` - 5xx status codes (Server Error).

  ## Examples

      iex> NeoFaker.HTTP.status_code()
      "200"

      iex> NeoFaker.HTTP.status_code(type: :detailed)
      "200 OK"

      iex> NeoFaker.HTTP.status_code(type: :simple)
      "404"

      iex> NeoFaker.HTTP.status_code(group: :client_error)
      "404"

      iex> NeoFaker.HTTP.status_code(type: :detailed, group: :success)
      "201 Created"

  """
  @spec status_code(Keyword.t()) :: String.t()
  def status_code(opts \\ []) do
    type = Options.get(opts, :type, :simple)
    group = Options.get(opts, :group, nil)

    validate_status_code_type!(type)
    validate_status_code_group!(group)

    group
    |> StatusCode.generates!()
    |> StatusCode.number(type: type)
  end

  @doc """
  Generates a random HTTP protocol version.

  Returns a random HTTP protocol version string.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:include_http3` - When `true`, includes HTTP/3. Defaults to `true`.

  ## Examples

      iex> NeoFaker.HTTP.protocol_version()
      "HTTP/1.1"

      iex> NeoFaker.HTTP.protocol_version()
      "HTTP/2"

      iex> NeoFaker.HTTP.protocol_version(include_http3: false)
      "HTTP/1.1"

  """
  @spec protocol_version(Keyword.t()) :: String.t()
  def protocol_version(opts \\ []) do
    include_http3 = Options.get(opts, :include_http3, true)

    versions = ["HTTP/1.0", "HTTP/1.1", "HTTP/2"]

    versions =
      if include_http3 do
        versions ++ ["HTTP/3"]
      else
        versions
      end

    Enum.random(versions)
  end

  @doc """
  Generates a random HTTP header name.

  Returns a random common HTTP header name.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - The type of header. Defaults to `:all`.

  ## Options

  The values for `:type` can be:

  - `:all` - All common headers (default).
  - `:request` - Request headers only.
  - `:response` - Response headers only.

  ## Examples

      iex> NeoFaker.HTTP.header_name()
      "Content-Type"

      iex> NeoFaker.HTTP.header_name(type: :request)
      "User-Agent"

      iex> NeoFaker.HTTP.header_name(type: :response)
      "Server"

  """
  @spec header_name(Keyword.t()) :: String.t()
  def header_name(opts \\ []) do
    type = Options.get(opts, :type, :all)

    request_headers = [
      "Accept",
      "Accept-Encoding",
      "Accept-Language",
      "Authorization",
      "Cache-Control",
      "Connection",
      "Cookie",
      "Host",
      "Referer",
      "User-Agent"
    ]

    response_headers = [
      "Access-Control-Allow-Origin",
      "Content-Encoding",
      "Content-Length",
      "Content-Type",
      "Date",
      "ETag",
      "Expires",
      "Last-Modified",
      "Server",
      "Set-Cookie"
    ]

    headers =
      case type do
        :request ->
          request_headers

        :response ->
          response_headers

        :all ->
          request_headers ++ response_headers

        _ ->
          raise ArgumentError,
                "Invalid header type. Expected one of [:all, :request, :response], got: #{inspect(type)}"
      end

    Enum.random(headers)
  end

  @doc """
  Returns a list of all valid HTTP request methods.

  ## Examples

      iex> NeoFaker.HTTP.all_request_methods()
      ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE", "CONNECT"]

  """
  @spec all_request_methods() :: [String.t()]
  def all_request_methods, do: @valid_request_methods

  @doc """
  Returns a list of all valid referrer policies.

  ## Examples

      iex> NeoFaker.HTTP.all_referrer_policies()
      ["no-referrer", "no-referrer-when-downgrade", ...]

  """
  @spec all_referrer_policies() :: [String.t()]
  def all_referrer_policies, do: @valid_referrer_policies

  # Private functions

  @spec validate_user_agent_type!(atom()) :: :ok
  defp validate_user_agent_type!(type) do
    case Options.validate_enum(:type, type, @valid_user_agent_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_status_code_type!(atom()) :: :ok
  defp validate_status_code_type!(type) do
    case Options.validate_enum(:type, type, @valid_status_code_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_status_code_group!(atom() | nil) :: :ok
  defp validate_status_code_group!(nil), do: :ok

  defp validate_status_code_group!(group) do
    valid_groups = [nil | @valid_status_code_groups]

    case Options.validate_enum(:group, group, valid_groups) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
