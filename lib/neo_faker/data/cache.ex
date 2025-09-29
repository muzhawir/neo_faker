defmodule NeoFaker.Data.Cache do
  @moduledoc false

  alias NeoFaker.Data.Disk
  alias NeoFaker.Data.Resolver

  @doc """
  Fetches a persistent term value or generates it if not found.

  If the value is not found in `:persistent_term`, it calls `put_cache!/3` to load and cache the
  data, then retrieves it again.
  """
  @spec fetch!(atom(), atom(), String.t()) :: map()
  def fetch!(locale, module, file) do
    key = cache_key(locale, module, file)

    case :persistent_term.get(key, nil) do
      nil ->
        put_cache!(locale, module, file)

        :persistent_term.get(key)

      value ->
        value
    end
  end

  @doc """
  Loads and caches the locale data file into persistent_term.

  Raises `File.Error` if the file does not exist.
  """
  @spec put_cache!(atom(), atom(), String.t()) :: :ok
  def put_cache!(locale, module, file) do
    resolved_locale = Resolver.resolve_locale_config(locale)

    module_name = module |> Module.split() |> List.last() |> String.downcase()

    file_path = Path.join([Disk.data_path(), Atom.to_string(resolved_locale), module_name, file])

    if File.exists?(file_path) do
      :rand.seed(:exsplus, :os.timestamp())

      data =
        file_path
        |> Disk.fetch_file!()
        |> Map.new(fn {key, val} -> {key, val |> Stream.uniq() |> Enum.shuffle()} end)

      :persistent_term.put(cache_key(resolved_locale, module, file), data)
    else
      raise(File.Error, reason: :enoent)
    end
  end

  @doc """
  Generates a unique persistent_term key for the given locale, module, and file.

  The key is constructed by combining the lowercase module name, file name (without extension),
  and locale name, separated by underscores.
  """
  @spec cache_key(atom(), atom(), String.t()) :: atom()
  def cache_key(locale, module, file) do
    module_name = module |> Module.split() |> Enum.map_join("_", &String.downcase/1)

    file_name = file |> String.split(".") |> hd()

    locale_name = locale |> Atom.to_string() |> String.downcase()

    String.to_atom("#{module_name}_#{file_name}_#{locale_name}")
  end
end
