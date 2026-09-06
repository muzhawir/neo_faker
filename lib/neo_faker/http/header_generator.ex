defmodule NeoFaker.HTTP.HeaderGenerator do
  @moduledoc false

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
  Generates a random HTTP header name based on the specified type.

  Returns a randomly selected header name string.

  ## Parameters

  - `:request` - Returns a random request header name.
  - `:response` - Returns a random response header name.
  - `:all` - Returns a random header name from both request and response headers.
  """
  @spec name(atom()) :: String.t()
  def name(:request), do: Enum.random(@request_headers)
  def name(:response), do: Enum.random(@response_headers)
  def name(:all), do: Enum.random(@request_headers ++ @response_headers)

  def name(type) do
    raise ArgumentError,
          "Invalid header type. Expected one of [:all, :request, :response], got: #{inspect(type)}"
  end
end
