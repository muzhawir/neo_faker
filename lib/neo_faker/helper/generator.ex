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
  @spec fetch_data(atom(), String.t(), Keyword.t()) :: map() | list()
  def fetch_data(module, file, opts \\ []) do
    locale = Keyword.get(opts, :locale, "default")
    key = Keyword.get(opts, :key)

    load_data(locale, module, file, key)
  end

  # Load data from the persistent term
  defp load_data(locale, module, file, nil), do: Locale.load_persistent_term(locale, module, file)

  # Load data from the persistent term and return the specified key
  defp load_data(locale, module, file, key) do
    locale |> Locale.load_persistent_term(module, file) |> Map.fetch!(key)
  end
end
