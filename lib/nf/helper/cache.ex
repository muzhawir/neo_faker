defmodule Nf.Helper.Cache do
  @moduledoc false

  import Nf.Helper.Locale

  @typedoc "List of random values."
  @type data :: list() | nil

  @doc """
  Loads data from caches or creates new ones.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  @spec load_cache(String.t(), String.t(), String.t()) :: data()
  def load_cache(module, file, key) do
    case :persistent_term.get(key, nil) do
      nil ->
        store_persistent_term(module, file, key)
        :persistent_term.get("nf_#{module}_#{key}", nil)

      list ->
        list
    end
  end

  @doc """
  Loads data from the locale file and caches it using persistent term.

  This function retrieves the specified data from the locale file, shuffles it, and stores it in
  `:persistent_term`.
  """
  @spec store_persistent_term(String.t(), String.t(), String.t()) :: data()
  def store_persistent_term(module, file, key) do
    data =
      module
      |> read_locale_file(file)
      |> Map.get(key, [])
      |> Enum.shuffle()

    :persistent_term.put("nf_#{module}_#{key}", data)
  end
end
