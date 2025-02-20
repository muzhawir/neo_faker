defmodule NeoFaker.Helper.Locale do
  @moduledoc false

  @typedoc "Result of a single value or a list of random values."
  @type result :: String.t() | [String.t()]

  @typedoc "Cached data loaded from a locale file."
  @type cached_data :: list() | nil

  @base_data_path Path.join([File.cwd!(), "lib", "data"])

  @doc """
  Returns a random value or a list of random values.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  @spec random_value(atom(), String.t(), String.t(), integer()) :: result()
  def random_value(module, file, key, amount \\ 1) do
    module
    |> current_module()
    |> load_cache(file, key)
    |> random_result(amount)
  end

  @doc """
  Returns the name of the current module in lowercase.

  This function splits the module name into parts and returns the last part in lowercase.
  """
  @spec current_module(atom()) :: String.t()
  def current_module(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end

  @doc """
  Loads data from caches or creates new ones.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  @spec load_cache(String.t(), String.t(), String.t()) :: cached_data()
  def load_cache(module, file, key) do
    case :persistent_term.get(key, nil) do
      nil ->
        store_persistent_term(module, file, key)

        :persistent_term.get("nf_#{module}_#{key}")

      list ->
        list
    end
  end

  @doc """
  Loads data from the locale file and caches it using persistent term.

  This function retrieves the specified data from the locale file, shuffles it, and stores it in
  `:persistent_term`.
  """
  @spec store_persistent_term(String.t(), String.t(), String.t()) :: :ok
  def store_persistent_term(module, file, key) do
    data =
      module
      |> read_locale_file(file)
      |> Map.get(key, [])
      |> Enum.shuffle()

    :persistent_term.put("nf_#{module}_#{key}", data)
  end

  @doc """
  Reads and returns the content of a locale file as a map.

  If the file does not exist for the configured locale, it falls back to the `"default"` locale.
  """
  @spec read_locale_file(String.t(), String.t()) :: map()
  def read_locale_file(module, file) do
    locale_setting = Application.get_env(:neo_faker, :locale)
    locale_path = build_locale_path(locale_setting, module, file)

    if File.exists?(locale_path) do
      locale_path |> Code.eval_file() |> elem(0)
    else
      "default" |> build_locale_path(module, file) |> Code.eval_file() |> elem(0)
    end
  end

  @doc """
  Constructs the absolute file path for a locale-specific data file.
  """
  @spec build_locale_path(String.t(), String.t(), String.t()) :: String.t()
  def build_locale_path(locale, module, file_name) do
    Path.join([@base_data_path, locale, module, file_name])
  end

  @doc """
  Returns a random value or a list of random values.
  """
  @spec random_result([String.t()], integer()) :: result()
  def random_result(list, -1), do: Enum.shuffle(list)
  def random_result(list, 1), do: Enum.random(list)

  def random_result(list, amount) when amount > 1 do
    list |> Enum.shuffle() |> Enum.take(amount)
  end
end
