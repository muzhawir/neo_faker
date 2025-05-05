defmodule NeoFaker.Data.Generator do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Disk
  alias NeoFaker.Data.Resolver

  @doc """
  Generates a random value from the specified locale data file.

  Returns a random value from the specified locale data file, locale doesnt exist or `nil` it will
  return a random value from the default locale.

  ## Parameters

  - `module` - The module where the locale data is stored, e.g., `NeoFaker.App`.
  - `file` - The name of the data file within the module, e.g., `"author.exs"`.
  - `key` - The specific key within the data file, e.g., `"first_names"`, `"last_names"`.
  - `opts` - Additional options.

  ### Options

  - `:locale` - Specifies the locale to use, e.g., `:id_id`. If not provided, `nil` will be used,
    which loads the default locale.
  """
  @spec random_value(atom(), String.t(), String.t(), Keyword.t()) :: any()
  def random_value(module, file, key, opts \\ []) do
    locale_name = opts |> Keyword.get(:locale, nil) |> Resolver.resolve_locale_config()
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([Disk.data_path(), Atom.to_string(locale_name), module_name, file])

    if File.exists?(file_path) do
      generate_random_value(locale_name, module, file, key)
    else
      generate_random_value(:default, module, file, key)
    end
  end

  defp generate_random_value(locale, module, file, key) do
    Cache.generate!(locale, module, file)

    locale
    |> Cache.generate_key(module, file)
    |> :persistent_term.get()
    |> Map.get(key)
    |> Enum.random()
  end
end
