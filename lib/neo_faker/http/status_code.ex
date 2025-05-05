defmodule NeoFaker.Http.StatusCode do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]

  
  
  @doc """
  Retrieves all HTTP status codes from the cache as a flattened list.
  
  Returns a list of all HTTP status code strings available in the cache when called with `nil`.
  """
  def fetch_status_codes!(nil) do
    :default
    |> fetch_cache!(NeoFaker.Http, "status_code.exs")
    |> Map.values()
    |> List.flatten()
  end

  @doc """
  Retrieves a list of HTTP status codes for the specified group from the cache.
  
  If `group` is `nil`, returns a flattened list of all status codes across all groups.
  If `group` is an atom, returns the list of status codes for that group.
  
  ## Examples
  
      iex> fetch_status_codes!(nil)
      ["200 OK", "404 Not Found", ...]
  
      iex> fetch_status_codes!(:success)
      ["200 OK", "201 Created", ...]
  """
  @spec fetch_status_codes!(atom() | nil) :: [String.t()]
  def fetch_status_codes!(group) do
    :default
    |> fetch_cache!(NeoFaker.Http, "status_code.exs")
    |> Map.get(Atom.to_string(group))
  end

  
  
  @doc """
Generates a random HTTP status code string from the provided list.

If the `:type` option is set to `:detailed`, returns a random full status code string (e.g., "404 Not Found"). If set to `:simple`, returns only the numeric part of a random status code (e.g., "404").
"""
def generate_status_code(status_codes, type: :detailed), do: Enum.random(status_codes)

  @doc """
  Selects a random HTTP status code number from a list of status code strings.
  
  Given a list of status code strings (e.g., "404 Not Found"), extracts the numeric part from each and returns one at random.
  """
  @spec generate_status_code([String.t()], type: :simple) :: String.t()
  def generate_status_code(status_codes, type: :simple) do
    get_status_number = fn code -> code |> String.split(" ", parts: 2) |> List.first() end

    status_codes |> Enum.map(&get_status_number.(&1)) |> Enum.random()
  end
end
