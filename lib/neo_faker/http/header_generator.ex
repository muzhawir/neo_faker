defmodule NeoFaker.HTTP.HeaderGenerator do
  @moduledoc false

  # A representative sample of common header names, not every header the HTTP
  # specifications define.
  @request_headers [
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

  @response_headers [
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

  @doc """
  Returns a random header name from the given category, or from both for `:all`.
  """
  @spec name(:all | :request | :response) :: String.t()
  def name(:request), do: Enum.random(@request_headers)
  def name(:response), do: Enum.random(@response_headers)
  def name(:all), do: Enum.random(@request_headers ++ @response_headers)
end
