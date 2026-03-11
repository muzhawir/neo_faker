defmodule NeoFaker.HTTP.Header do
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

  @spec name(atom()) :: String.t()
  def name(:request), do: Enum.random(@request_headers)
  def name(:response), do: Enum.random(@response_headers)
  def name(:all), do: Enum.random(@request_headers ++ @response_headers)

  def name(type) do
    raise ArgumentError,
          "Invalid header type. Expected one of [:all, :request, :response], got: #{inspect(type)}"
  end
end
