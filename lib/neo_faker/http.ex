defmodule NeoFaker.HTTP do
  @moduledoc """
  Functions for generating HTTP-related data.

  Provides utilities to generate random HTTP values including user-agent strings, request
  methods, status codes, referrer policies, protocol versions, and header names.
  """
  @moduledoc since: "0.11.0"

  alias NeoFaker.Helpers.Options
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

  @user_agent_schema NimbleOptions.new!(
                       type: [type: {:in, [:all, :browser, :crawler]}, default: :all]
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
  @spec user_agent(keyword()) :: String.t()
  def user_agent(opts \\ []) do
    opts = Options.validate!(opts, @user_agent_schema)
    UserAgentGenerator.name(Keyword.fetch!(opts, :type))
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
  @spec request_method(keyword()) :: String.t()
  def request_method(opts \\ []) do
    opts = Options.validate!(opts, @request_method_schema)

    methods =
      if Keyword.fetch!(opts, :common_only) do
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
  @spec status_code(keyword()) :: String.t()
  def status_code(opts \\ []) do
    opts = Options.validate!(opts, @status_code_schema)

    opts
    |> Keyword.fetch!(:group)
    |> StatusCodeGenerator.generates!()
    |> StatusCodeGenerator.number(type: Keyword.fetch!(opts, :type))
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
  @spec protocol_version(keyword()) :: String.t()
  def protocol_version(opts \\ []) do
    opts = Options.validate!(opts, @protocol_version_schema)

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
  @spec header_name(keyword()) :: String.t()
  def header_name(opts \\ []) do
    opts = Options.validate!(opts, @header_name_schema)
    HeaderGenerator.name(Keyword.fetch!(opts, :type))
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
