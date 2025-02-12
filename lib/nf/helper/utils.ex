defmodule Nf.Helper.Utils do
  @moduledoc false

  @base_data_path Path.join([File.cwd!(), "lib", "data"])

  @doc """
  Loads data from caches or creates new ones.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  @spec load_cache(String.t(), String.t(), String.t()) :: list() | nil
  def load_cache(module, file, key) do
    case :persistent_term.get(key, nil) do
      nil -> store_persistent_term(module, file, key)
      list -> list
    end
  end

  # Loads data from the locale file and caches it using persistent term.
  #
  # This function retrieves the specified data from the locale file, shuffles it, and stores it in
  # `:persistent_term`.
  @spec store_persistent_term(String.t(), String.t(), String.t()) :: list() | nil
  defp store_persistent_term(module, file, key) do
    data =
      module
      |> read_locale_file(file)
      |> Map.get(key, [])
      |> Enum.shuffle()

    cache_key = "nf_#{module}_#{key}"

    :persistent_term.put(cache_key, data)

    :persistent_term.get(cache_key, nil)
  end

  # Reads and returns the content of a locale file as a map.
  #
  # If the file does not exist for the configured locale, it falls back to the `"default"` locale.
  @spec read_locale_file(String.t(), String.t()) :: map()
  defp read_locale_file(module, file) do
    locale_setting = Application.get_env(:neo_faker, :locale)
    locale_path = build_locale_path(locale_setting, module, file)

    if File.exists?(locale_path) do
      locale_path |> Code.eval_file() |> elem(0)
    else
      "default" |> build_locale_path(module, file) |> Code.eval_file() |> elem(0)
    end
  end

  # Constructs the absolute file path for a locale-specific data file.
  @spec build_locale_path(String.t(), String.t(), String.t()) :: String.t()
  defp build_locale_path(locale, module, file_name) do
    Path.join([@base_data_path, locale, module, file_name])
  end

  @doc """
  Returns a random value or a list of random values.
  """
  @spec random_result([String.t()], integer()) :: String.t() | [String.t()]
  def random_result(cache, 1), do: Enum.random(cache)
  def random_result(cache, -1), do: Enum.shuffle(cache)
  def random_result(cache, amount), do: cache |> Enum.shuffle() |> Enum.take(amount)
end
