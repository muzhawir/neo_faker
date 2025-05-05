defmodule NeoFaker.Data.Cache do
  @moduledoc false

  alias NeoFaker.Data.Disk
  alias NeoFaker.Data.Resolver

  @data_path Path.join([File.cwd!(), "priv", "data"])

  @spec fetch_cache!(atom(), atom(), String.t()) :: map()
  def fetch_cache!(locale, module, file) do
    key = generate_persistent_term_key(locale, module, file)

    if :persistent_term.get(key, nil) == nil do
      generate_cache!(locale, module, file)

      :persistent_term.get(key)
    else
      :persistent_term.get(key)
    end
  end

  @doc """
  Create a persistent term with value in locale data file.
  """
  @spec generate_cache!(atom(), atom(), String.t()) :: :ok | File.Error
  def generate_cache!(locale, module, file) do
    locale_name = Resolver.resolve_locale_config(locale)
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([@data_path, Atom.to_string(locale_name), module_name, file])

    if File.exists?(file_path) do
      value =
        file_path
        |> Disk.evaluate_file!()
        |> Map.new(fn {key, val} -> {key, Enum.shuffle(val)} end)

      :persistent_term.put(generate_persistent_term_key(locale_name, module, file), value)
    else
      raise File.Error, reason: :enoent
    end
  end

  @doc """
  Creates a persistent term key based on the given locale, module, and file name.
  """
  @spec generate_persistent_term_key(atom(), atom(), String.t()) :: atom()
  def generate_persistent_term_key(locale, module, file) do
    module_name = module |> Module.split() |> Enum.map_join("_", &String.downcase/1)
    file_name = file |> String.split(".") |> List.first()
    locale_name = locale |> Atom.to_string() |> String.downcase()

    String.to_atom("#{module_name}_#{file_name}_#{locale_name}")
  end
end
