defmodule Nf.Helper do
  @moduledoc false

  @base_data_path Path.join([File.cwd!(), "lib", "data"])

  @doc """
  Returns a random value or a list of random values.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  def get_random_data(module_name, file_name, map_key, amount \\ 1) when amount > 0 do
    cache_name = "nf_#{module_name}_#{map_key}"

    case_result =
      case :persistent_term.get(cache_name, nil) do
        nil -> store_persistent_term(module_name, file_name, map_key)
        list -> list
      end

    cached_list = Enum.shuffle(case_result)

    if amount == 1, do: Enum.random(cached_list), else: Enum.take(cached_list, amount)
  end

  @doc """
  Loads data from the locale file and caches it using persistent term.

  This function retrieves the specified data from the locale file, shuffles it, and stores it in
  `:persistent_term` for optimized performance.
  """
  def store_persistent_term(module_name, file_name, map_key) do
    cache_name = "nf_#{module_name}_#{map_key}"

    random_list =
      module_name
      |> read_locale_file(file_name)
      |> Map.get(map_key, [])
      |> Enum.shuffle()

    :persistent_term.put(cache_name, random_list)

    random_list
  end

  @doc """
  Reads and returns the content of a locale file as a map.

  If the file does not exist for the configured locale, it falls back to the `"default"` locale.
  """
  @spec read_locale_file(String.t(), String.t()) :: map()
  def read_locale_file(module_name, file_name) do
    path =
      :neo_faker
      |> Application.get_env(:locale)
      |> build_locale_path(module_name, file_name)

    if File.exists?(path) do
      load_locale_file(path)
    else
      load_locale_file(build_locale_path("default", module_name, file_name))
    end
  end

  @doc """
  Loads and evaluates the given locale file.

  Reads an `.exs` file from the specified `path`, evaluates its content, and returns the resulting map.
  """
  @spec load_locale_file(String.t()) :: map()
  def load_locale_file(path), do: path |> Code.eval_file() |> elem(0)

  @doc """
  Constructs the absolute file path for a locale-specific data file.
  """
  @spec build_locale_path(String.t(), String.t(), String.t()) :: String.t()
  def build_locale_path(locale, module, file_name) do
    Path.join([@base_data_path, locale, module, file_name])
  end
end
