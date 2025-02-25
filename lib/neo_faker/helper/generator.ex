defmodule NeoFaker.Helper.Generator do
  @moduledoc false

  alias NeoFaker.Helper.Locale

  @doc """
  Returns a random value.

  Return a random value from specified locale file.
  """
  @spec random(atom(), String.t(), String.t(), Keyword.t()) :: String.t()
  def random(module, file, key, opts \\ []) do
    module
    |> fetch_data(file, opts)
    |> Map.get(key)
    |> Enum.random()
  end

  @doc """
  Fetches data from the persistent term.

  Fetches data from the persistent term, if the data is not found, it will be loaded from the
  locale file first.
  """
  @spec fetch_data(atom(), String.t(), Keyword.t()) :: map()
  def fetch_data(module, file, opts \\ []) do
    opts |> Keyword.get(:locale, "default") |> Locale.load_persistent_term(module, file)
  end
end
