defmodule NeoFaker.Data do
  @moduledoc false

  @locale_file Path.join([File.cwd!(), "priv", "data", "locale.exs"])

  # ---------------------------------------------------------------------------
  # Public API – used by every faker module
  # ---------------------------------------------------------------------------

  @doc """
  Returns a random value from the specified locale data file.

  ## Parameters

    - `module`  – The caller module (used to derive the data subdirectory).
    - `file`    – The data file name (e.g. `"author.exs"`).
    - `key`     – The key inside the data file (e.g. `"first_names"`).
    - `opts`    – Keyword options. Supports `:locale`.
  """
  @spec random_value(atom(), String.t(), String.t(), Keyword.t()) :: any()
  def random_value(module, file, key, opts \\ []) do
    locale =
      opts[:locale]
      |> resolve_locale_config()
      |> ensure_locale_file_exists(module, file)

    locale
    |> fetch!(module, file)
    |> Map.fetch!(key)
    |> Enum.random()
  end

  @doc """
  Fetches the full cached map for a given locale / module / file combination.

  If the data has not been cached yet it is loaded from disk and stored in
  `:persistent_term` automatically.
  """
  @spec fetch!(atom(), atom(), String.t()) :: map()
  def fetch!(locale, module, file) do
    resolved_locale = resolve_locale_config(locale)
    key = cache_key(resolved_locale, module, file)

    case :persistent_term.get(key, nil) do
      nil ->
        put_cache!(resolved_locale, module, file)
        :persistent_term.get(key)

      value ->
        value
    end
  end

  # ---------------------------------------------------------------------------
  # Locale resolution (formerly Data.Resolver)
  # ---------------------------------------------------------------------------

  @doc """
  Resolves the locale to use, falling back to the app config or `:default`.
  """
  @spec resolve_locale_config(nil | atom()) :: atom()
  def resolve_locale_config(nil) do
    :neo_faker |> Application.get_env(:locale) |> resolve_locale()
  end

  def resolve_locale_config(locale), do: resolve_locale(locale)

  # ---------------------------------------------------------------------------
  # Disk helpers (formerly Data.Disk)
  # ---------------------------------------------------------------------------

  @doc """
  Returns the path to the `priv/data` directory.
  """
  @spec data_path() :: String.t()
  def data_path, do: :neo_faker |> :code.priv_dir() |> to_string() |> Path.join("data")

  # ---------------------------------------------------------------------------
  # Internals
  # ---------------------------------------------------------------------------

  @spec resolve_locale(atom()) :: atom()
  defp resolve_locale(locale), do: if(locale_available?(locale), do: locale, else: :default)

  @spec locale_available?(atom()) :: boolean()
  defp locale_available?(locale) do
    locales =
      case :persistent_term.get(:available_locales, nil) do
        nil ->
          loaded = @locale_file |> read_data_file!() |> MapSet.new()
          :persistent_term.put(:available_locales, loaded)
          loaded

        loaded ->
          loaded
      end

    MapSet.member?(locales, Atom.to_string(locale))
  end

  @spec read_data_file!(String.t()) :: any()
  defp read_data_file!(path) do
    path |> File.read!() |> Code.eval_string([], __ENV__) |> elem(0)
  end

  @spec put_cache!(atom(), atom(), String.t()) :: :ok
  defp put_cache!(locale, module, file) do
    module_name = module_dir_name(module)
    file_path = Path.join([data_path(), Atom.to_string(locale), module_name, file])

    if File.exists?(file_path) do
      :rand.seed(:exsplus, :os.timestamp())

      data =
        file_path
        |> read_data_file!()
        |> Map.new(fn {key, val} -> {key, val |> Stream.uniq() |> Enum.shuffle()} end)

      :persistent_term.put(cache_key(locale, module, file), data)
    else
      raise(File.Error, reason: :enoent)
    end
  end

  @spec cache_key(atom(), atom(), String.t()) :: atom()
  defp cache_key(locale, module, file) do
    module_name = module |> Module.split() |> Enum.map_join("_", &String.downcase/1)
    file_name = file |> String.split(".") |> hd()
    locale_name = locale |> Atom.to_string() |> String.downcase()

    String.to_atom("#{module_name}_#{file_name}_#{locale_name}")
  end

  @spec ensure_locale_file_exists(atom(), atom(), String.t()) :: atom()
  defp ensure_locale_file_exists(locale, module, file) do
    module_name = module_dir_name(module)
    file_path = Path.join([data_path(), Atom.to_string(locale), module_name, file])

    if File.exists?(file_path), do: locale, else: :default
  end

  @spec module_dir_name(atom()) :: String.t()
  defp module_dir_name(module) do
    module |> Module.split() |> List.last() |> String.downcase()
  end
end
