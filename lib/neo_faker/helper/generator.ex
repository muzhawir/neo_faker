defmodule NeoFaker.Helper.Generator do
  @moduledoc false

  alias NeoFaker.Helper.Locale

  @doc """
  Retrieves a random value from the specified locale data file.

  This function fetches a random value from a locale-specific data file. A key can be specified
  to extract a particular value from the map.

  ## Parameters

  - `module` - The module where the locale data is stored, e.g., `NeoFaker.App`.
  - `file` - The name of the data file within the module, e.g., `"author.exs"`.
  - `key` - The specific key within the data file, e.g., `"first_names"`, `"last_names"`.
  - `opts` - Additional options (optional).

  ### Options

  - `:locale` - Specifies the locale to use, e.g., `"id_id"`. If not provided, `nil` will be used,
  which loads the default locale.
  """
  @spec random(atom(), String.t(), String.t(), Keyword.t()) :: String.t()
  def random(module, file, key, opts \\ []) do
    module
    |> fetch_data(file, opts)
    |> Map.get(key)
    |> Enum.random()
  end

  @doc """
  Retrieves data from the persistent term.

  If the requested data is not found, it will be loaded from the corresponding locale file first.
  """
  @spec fetch_data(atom(), String.t(), Keyword.t()) :: map() | list()
  def fetch_data(module, file, opts \\ []) do
    locale = Keyword.get(opts, :locale, "default")
    key = Keyword.get(opts, :key)

    load_data(locale, module, file, key)
  end

  # Loads data from the persistent term if no cached data is available.
  defp load_data(locale, module, file, nil), do: Locale.load_persistent_term(locale, module, file)

  # Loads data from the persistent term and retrieves the specified key.
  # If the key is not found, it returns `nil`.
  defp load_data(locale, module, file, key) do
    locale |> Locale.load_persistent_term(module, file) |> Map.get(key)
  end
end
