defmodule NeoFaker.Data do
  @moduledoc false

  # The single data-loading layer every domain module goes through instead of
  # touching `priv/data/**` directly. It resolves which locale applies, loads
  # the right `.exs` file, caches it in `:persistent_term`, and hands back one
  # random value. `@moduledoc false` hides this from ExDoc since it's plumbing,
  # not something a NeoFaker user should ever call directly, but its functions
  # stay real `def`s (not `defp`) because every domain module across the
  # `NeoFaker.*` namespace needs to call into it.

  alias NeoFaker.Locale

  # ---------------------------------------------------------------------------
  # Entry points used by every domain module
  # ---------------------------------------------------------------------------

  @doc """
  Returns a random value from the specified locale data file.

  This is what a domain module's public function calls to get one value out of
  its data file, so it's the one function most call sites in `lib/neo_faker/`
  actually use, `fetch!/3` below is for reaching the raw cached map instead.

    * `module` - the calling module, used to derive the data subdirectory
      (e.g. `NeoFaker.Person` reads from `priv/data/<locale>/person/`).
    * `file` - the bare data file name, e.g. `"first_names.exs"`. Must pass
      `validate_file_name!/1`.
    * `key` - the map key to read inside that file, e.g. `"first_names"`.
    * `opts` - forwarded from the caller; only `:locale` is read here.
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
  Fetches the full cached map for a given locale, module, and file.

  `random_value/4` calls this and then picks one value out of it; tests call
  it directly to get the whole list a domain function draws from, so they can
  assert a generated value came from the real data set instead of hardcoding
  a copy of it. Loads from disk into `:persistent_term` on the first call for
  a given locale/module/file triple; every call after that is a cache hit.
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
  # Locale resolution
  # ---------------------------------------------------------------------------

  @doc """
  Resolves the locale to use, falling back to `NeoFaker.Locale.get/0` (which
  itself checks the calling process's override, then the app config) when no
  explicit `locale` is given.

  This only decides *which locale the caller wants*; it doesn't check whether
  that locale actually has the requested file. `ensure_locale_file_exists/3`,
  called separately by `random_value/4`, handles the per-file fallback.
  """
  @spec resolve_locale_config(nil | atom()) :: atom()
  def resolve_locale_config(nil), do: resolve_locale(Locale.get())
  def resolve_locale_config(locale), do: resolve_locale(locale)

  # ---------------------------------------------------------------------------
  # Disk helpers
  # ---------------------------------------------------------------------------

  @doc """
  Returns the path to the `priv/data` directory.

  Goes through `:code.priv_dir/1` rather than a path relative to this source
  file, so it still resolves correctly once the app is compiled into a
  release, where `priv/` moves alongside the compiled `.beam` files instead of
  staying next to `lib/`.
  """
  @spec data_path() :: String.t()
  def data_path, do: :neo_faker |> :code.priv_dir() |> to_string() |> Path.join("data")

  # ---------------------------------------------------------------------------
  # Internals
  # ---------------------------------------------------------------------------

  # A requested locale that isn't registered in priv/data/locale.exs silently
  # becomes :default, the same way a missing per-file override does elsewhere
  # in this module, so an unsupported `locale:` option never raises here.
  # NeoFaker.Locale.set/1 is the layer that raises for that instead, at the
  # point the caller sets the locale rather than every time data is read.
  @spec resolve_locale(atom()) :: atom()
  defp resolve_locale(locale), do: if(Locale.available?(locale), do: locale, else: :default)

  # Every locale data file is a bare `%{...}` map literal, so evaluating it is
  # enough to get the data back; there's no need for a real Code.exs loader.
  @spec read_data_file!(String.t()) :: any()
  defp read_data_file!(path) do
    path |> File.read!() |> Code.eval_string([], __ENV__) |> elem(0)
  end

  # Reads `locale`'s file from disk and caches it. Only called after
  # ensure_locale_file_exists/3 has already picked a locale known to have the
  # file, so the `File.exists?/1` check here is a defensive re-check, not the
  # place fallback-to-:default happens.
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

  # This is the actual per-file fallback: a locale can be fully registered and
  # still not have every file (e.g. :id_id has no http/user_agent.exs), so
  # each lookup checks the specific file it needs rather than trusting the
  # locale as a whole.
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

  # Every domain module's data lives under its own last name segment, so
  # NeoFaker.Person reads priv/data/<locale>/person/, not a name configured
  # anywhere, this derivation is the only thing making that mapping automatic.
  @spec module_dir_name(atom()) :: String.t()
  defp module_dir_name(module) do
    module |> Module.split() |> List.last() |> String.downcase()
  end
end
