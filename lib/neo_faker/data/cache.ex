defmodule NeoFaker.Data.Cache do
  @moduledoc false

  alias NeoFaker.Data.Disk
  alias NeoFaker.Data.Resolver

  @spec fetch!(atom(), atom(), String.t()) :: map()
  def fetch!(locale, module, file) do
    key = generate_key(locale, module, file)

    case :persistent_term.get(key, nil) do
      nil ->
        generate!(locale, module, file)

        :persistent_term.get(key)

      value ->
        value
    end
  end

  @doc """
  Creates a persistent term with the value from the locale data file.
  """
  @spec generate!(atom(), atom(), String.t()) :: :ok | File.Error
  def generate!(locale, module, file) do
    resolved_locale = Resolver.resolve_locale_config(locale)
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([Disk.data_path(), Atom.to_string(resolved_locale), module_name, file])

    if File.exists?(file_path) do
      file_path
      |> Disk.evaluate_file!()
      |> Map.new(fn {key, value} -> {key, Enum.shuffle(value)} end)
      |> put_in_persistent_term(resolved_locale, module, file)
    else
      raise File.Error, reason: :enoent
    end
  end

  defp put_in_persistent_term(value, locale, module, file) do
    :persistent_term.put(generate_key(locale, module, file), value)
  end

  @doc """
  Generates a persistent term key based on the given locale, module, and file name.
  """
  @spec generate_key(atom(), atom(), String.t()) :: atom()
  def generate_key(locale, module, file) do
    module_name = module |> Module.split() |> Enum.map_join("_", &String.downcase/1)
    file_name = file |> String.split(".") |> List.first()
    locale_name = locale |> Atom.to_string() |> String.downcase()

    String.to_atom("#{module_name}_#{file_name}_#{locale_name}")
  end
end
