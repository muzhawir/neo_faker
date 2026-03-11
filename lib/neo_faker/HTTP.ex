defmodule NeoFaker.HTTP do
  @moduledoc """
  Functions for generating HTTP-related data.

  Provides utilities to generate random HTTP values including user-agent strings, request
  methods, status codes, referrer policies, protocol versions, and header names.
  """
  @moduledoc since: "0.11.0"

  alias NeoFaker.Helpers.Options
  alias NeoFaker.HTTP.Header
  alias NeoFaker.HTTP.StatusCode
  alias NeoFaker.HTTP.UserAgent
  alias NeoFaker.HTTP.Validator

  @request_methods [
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

  @doc """
  Generates a random HTTP user-agent string.

  Returns a user-agent from the top 100 most common browser or crawler user-agents.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - User-agent category. Defaults to `:all`.

  ## Options

  The values for `:type` can be:

  - `:all` - Random user-agent from browsers and crawlers (default).
  - `:browser` - Browser user-agent only.
  - `:crawler` - Crawler user-agent only.

  ## Examples

      iex> NeoFaker.HTTP.user_agent()
      "Mozilla/5.0 (X11; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.HTTP.user_agent(type: :browser)
      "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:136.0) Gecko/20100101 Firefox/136.0"

      iex> NeoFaker.HTTP.user_agent(type: :crawler)
      "Mozilla/5.0 (compatible; Google-InspectionTool/1.0)"

  """
  @spec user_agent(Keyword.t()) :: String.t()
  def user_agent(opts \\ []) do
    type = Options.get(opts, :type, :all)
    Validator.validate_user_agent_type!(type)
    UserAgent.name(type)
  end

  @doc """
  Generates a random HTTP request method.

  Returns one of the common methods (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`) by default.
  Pass `common_only: false` to include all nine standard methods.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:common_only` - When `true`, restricts to the five most common methods. Defaults to `true`.

  ## Examples

      iex> NeoFaker.HTTP.request_method()
      "GET"

      iex> NeoFaker.HTTP.request_method(common_only: false)
      "OPTIONS"

  """
  @spec request_method(Keyword.t()) :: String.t()
  def request_method(opts \\ []) do
    common_only = Options.get(opts, :common_only, true)

    methods =
      if common_only do
        ["GET", "POST", "PUT", "DELETE", "PATCH"]
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

  Returns either a simple code string (e.g. `"200"`) or a detailed one (e.g. `"200 OK"`),
  optionally filtered to a specific status group.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Output format. Defaults to `:simple`.
    - `:group` - Status code group to sample from. Defaults to `nil` (all groups).

  ## Options

  The values for `:type` can be:

  - `:simple` - Code only, e.g. `"200"` (default).
  - `:detailed` - Code with reason phrase, e.g. `"200 OK"`.

  The values for `:group` can be:

  - `nil` - All status codes (default).
  - `:information` - 1xx Informational.
  - `:success` - 2xx Success.
  - `:redirection` - 3xx Redirection.
  - `:client_error` - 4xx Client Error.
  - `:server_error` - 5xx Server Error.

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
  @spec status_code(Keyword.t()) :: String.t()
  def status_code(opts \\ []) do
    type = Options.get(opts, :type, :simple)
    group = Options.get(opts, :group, nil)

    Validator.validate_status_code_type!(type)
    Validator.validate_status_code_group!(group)

    group
    |> StatusCode.generates!()
    |> StatusCode.number(type: type)
  end

  @doc """
  Generates a random HTTP protocol version string.

  Randomly selects from `HTTP/1.0`, `HTTP/1.1`, `HTTP/2`, and optionally `HTTP/3`.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:include_http3` - When `true`, includes `HTTP/3` in the pool. Defaults to `true`.

  ## Examples

      iex> NeoFaker.HTTP.protocol_version()
      "HTTP/1.1"

      iex> NeoFaker.HTTP.protocol_version(include_http3: false)
      "HTTP/1.0"

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

  Returns a common request or response header name from a curated list of ten per category.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Header category. Defaults to `:all`.

  ## Options

  The values for `:type` can be:

  - `:all` - Request and response headers combined (default).
  - `:request` - Request headers only, e.g. `"User-Agent"`.
  - `:response` - Response headers only, e.g. `"Server"`.

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
    Header.name(type)
  end

  @doc """
  Returns the list of all valid HTTP request methods.

  ## Examples

      iex> NeoFaker.HTTP.all_request_methods()
      ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS", "TRACE", "CONNECT"]

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
