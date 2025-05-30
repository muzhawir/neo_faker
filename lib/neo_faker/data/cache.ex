defmodule NeoFaker.Data.Cache do
  @moduledoc false

  alias NeoFaker.Data.Disk
  alias NeoFaker.Data.Resolver

  @doc """
  Fetches a persistent term value or generates it if not found.
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
  """
  @spec put_cache!(atom(), atom(), String.t()) :: :ok
  def put_cache!(locale, module, file) do
    resolved_locale = Resolver.resolve_locale_config(locale)
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([Disk.data_path(), Atom.to_string(resolved_locale), module_name, file])

    if !File.exists?(file_path) do
      raise File.Error, reason: :enoent
    end

    emit_duplicate_data_and_shuffle = fn data -> data |> Stream.uniq() |> Enum.shuffle() end

    data =
      file_path
      |> Disk.fetch_file!()
      |> Map.new(fn {k, v} -> {k, emit_duplicate_data_and_shuffle.(v)} end)

    :persistent_term.put(cache_key(resolved_locale, module, file), data)
  end

  @doc """
  Generates a unique persistent_term key for the given locale, module, and file.
  """
  @spec cache_key(atom(), atom(), String.t()) :: atom()
  def cache_key(locale, module, file) do
    module_name = module |> Module.split() |> Enum.map_join("_", &String.downcase/1)
    file_name = file |> String.split(".") |> hd()
    locale_name = locale |> Atom.to_string() |> String.downcase()

    String.to_atom("#{module_name}_#{file_name}_#{locale_name}")
  end
end
