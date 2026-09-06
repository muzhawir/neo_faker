defmodule NeoFaker.HTTP.StatusCodeGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @type status_code_type :: :detailed | :simple

  @doc """
  Generates a list of HTTP status codes for the specified group from the cache.

  If `group` is `nil`, returns a flattened list of all status codes across all groups.
  If `group` is an atom, returns the list of status codes for that group.
  """
  @spec generates!(atom()) :: list(String.t())
  def generates!(nil) do
    :default
    |> Data.fetch!(NeoFaker.HTTP, "status_code.exs")
    |> Map.values()
    |> List.flatten()
  end

  def generates!(group) do
    :default
    |> Data.fetch!(NeoFaker.HTTP, "status_code.exs")
    |> Map.get(Atom.to_string(group))
  end

  @doc """
  Generates a random HTTP status code string from the provided list.

  If the `:type` option is set to `:detailed`, returns a random full status code string
  (e.g., "404 Not Found"). If set to `:simple`, returns only the numeric part of a random
  status code (e.g., "404").
  """
  @spec number([String.t()], type: status_code_type()) :: String.t()
  def number(status_codes, type: :detailed), do: Enum.random(status_codes)

  def number(status_codes, type: :simple) do
    status_codes
    |> Stream.map(&(&1 |> String.split(" ", parts: 2) |> List.first()))
    |> Enum.random()
  end
end
