defmodule NeoFaker.Locale.Cache do
  @moduledoc false

  alias NeoFaker.Locale.Disk
  alias NeoFaker.Locale.Resolver

  @data_path Path.join([File.cwd!(), "lib", "data"])

  @doc """
  Create a persistent term with value in locale data file.
  """
  # @spec create_cache(atom(), atom(), String.t()) :: :ok
  def create_cache(locale, module, file) do
    locale_name = locale |> Resolver.resolve_locale_config() |> Atom.to_string()
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([@data_path, locale_name, module_name, file])

    if File.exists?(file_path) do
      value =
        file_path
        |> Disk.evaluate_file!()
        |> Map.new(fn {key, val} -> {key, Enum.shuffle(val)} end)

      :persistent_term.put(create_persistent_term_key(locale_name, module, file), value)
    else
      raise File.Error, reason: :enoent
    end
  end

  @doc """
  Creates a persistent term key based on the given locale, module, and file name.
  """
  @spec create_persistent_term_key(String.t(), atom(), String.t()) :: atom()
  def create_persistent_term_key(locale, module, file) do
    module_name = module |> Module.split() |> Enum.map_join("_", &String.downcase/1)
    file_name = file |> String.split(".") |> List.first()

    String.to_atom("#{module_name}_#{file_name}_#{locale}")
  end
end
