defmodule NeoFaker.Data do
  @moduledoc false

  @locale_file Path.join([:neo_faker |> :code.priv_dir() |> to_string(), "data", "locale.exs"])

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
  @spec random_value(atom(), String.t(), String.t(), keyword()) :: any()
  def random_value(module, file, key, opts \\ []) do
    validate_file_name!(file)

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
    validate_file_name!(file)
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
  Resolves the locale to use, falling back to `NeoFaker.get_locale/0` (which
  itself checks the calling process's override, then the app config) when no
  explicit `locale` is given.
  """
  @spec resolve_locale_config(nil | atom()) :: atom()
  def resolve_locale_config(nil), do: resolve_locale(NeoFaker.get_locale())
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

  @doc """
  Returns the sorted list of all supported locale atoms from `priv/data/locale.exs`.

  The `:default` sentinel is **not** included; use `locale_available?/1` or
  check for `:default` explicitly. Results are cached in `:persistent_term`
  after the first call, so repeated invocations are O(1).

  ## Examples

      iex> NeoFaker.Data.supported_locales()
      [:en_us, :id_id]

  """
  @spec supported_locales() :: [atom()]
  def supported_locales do
    load_locale_set() |> Enum.map(&String.to_atom/1) |> Enum.sort()
  end

  @doc """
  Returns `true` when `locale` is listed in `priv/data/locale.exs`, `false`
  otherwise.

  The result of reading `locale.exs` is cached in `:persistent_term` on the
  first call, so subsequent calls are O(1) lookups.
  """
  @spec locale_available?(atom()) :: boolean()
  def locale_available?(locale) do
    MapSet.member?(load_locale_set(), Atom.to_string(locale))
  end

  # Loads (or retrieves from cache) the MapSet of locale strings from locale.exs.
  @spec load_locale_set() :: MapSet.t(String.t())
  defp load_locale_set do
    key = {__MODULE__, :available_locales}

    case :persistent_term.get(key, nil) do
      nil ->
        loaded = @locale_file |> read_data_file!() |> MapSet.new()
        :persistent_term.put(key, loaded)
        loaded

      loaded ->
        loaded
    end
  end

  @spec read_data_file!(String.t()) :: any()
  defp read_data_file!(path) do
    path |> File.read!() |> Code.eval_string([], __ENV__) |> elem(0)
  end

  @spec put_cache!(atom(), atom(), String.t()) :: :ok
  defp put_cache!(locale, module, file) do
    module_name = module_dir_name(module)

    file_path =
      Path.join([data_path(), Atom.to_string(locale), module_name, validate_file_name!(file)])

    if File.exists?(file_path) do
      data =
        file_path
        |> read_data_file!()
        |> Map.new(fn {key, val} -> {key, Enum.uniq(val)} end)

      :persistent_term.put(cache_key(locale, module, file), data)
    else
      raise(File.Error, reason: :enoent)
    end
  end

  @spec cache_key(atom(), atom(), String.t()) :: tuple()
  defp cache_key(locale, module, file) do
    {__MODULE__, locale, module, Path.rootname(file)}
  end

  @spec ensure_locale_file_exists(atom(), atom(), String.t()) :: atom()
  defp ensure_locale_file_exists(locale, module, file) do
    module_name = module_dir_name(module)

    file_path =
      Path.join([data_path(), Atom.to_string(locale), module_name, validate_file_name!(file)])

    if File.exists?(file_path), do: locale, else: :default
  end

  # Validates that `file` is a bare filename (no directory component) with a
  # `.exs` extension. Raises `ArgumentError` on any other value, preventing
  # path traversal and arbitrary-file evaluation via `Code.eval_string/3`.
  @spec validate_file_name!(String.t()) :: String.t()
  defp validate_file_name!(file) when is_binary(file) do
    if file != "" and Path.basename(file) == file and Path.extname(file) == ".exs" do
      file
    else
      raise ArgumentError,
            "invalid data file name #{inspect(file)}. " <>
              "Expected a bare filename with a .exs extension, e.g. \"word.exs\"."
    end
  end

  defp validate_file_name!(file) do
    raise ArgumentError,
          "data file name must be a string, got: #{inspect(file)}"
  end

  @spec module_dir_name(atom()) :: String.t()
  defp module_dir_name(module) do
    module |> Module.split() |> List.last() |> String.downcase()
  end
end
