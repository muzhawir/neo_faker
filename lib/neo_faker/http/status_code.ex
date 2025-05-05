defmodule NeoFaker.Http.StatusCode do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]

  @doc """
  Fetches HTTP status codes from the cache.

  Returns a list of HTTP status codes for the specified group. If no group is specified, it
  returns all status codes.
  """
  @spec fetch_status_codes!(atom()) :: list(String.t())
  def fetch_status_codes!(nil) do
    :default
    |> fetch_cache!(NeoFaker.Http, "status_code.exs")
    |> Map.values()
    |> List.flatten()
  end

  def fetch_status_codes!(group) do
    :default
    |> fetch_cache!(NeoFaker.Http, "status_code.exs")
    |> Map.fetch!(Atom.to_string(group))
  end

  @doc """
  Generates a random HTTP status code.

  Returns a random HTTP status code string wether detailed or simple based on the provided
  options.
  """
  @spec generate_status_code(list(), Keyword.t()) :: String.t()
  def generate_status_code(status_codes, type: :detailed), do: Enum.random(status_codes)

  def generate_status_code(status_codes, type: :simple) do
    get_status_number = fn code -> code |> String.split(" ", parts: 2) |> List.first() end

    status_codes |> Enum.map(&get_status_number.(&1)) |> Enum.random()
  end
end
