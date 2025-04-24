defmodule NeoFaker.Data.Generator do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Resolver

  @data_path Path.join([File.cwd!(), "lib", "data"])

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
  @spec random_data(atom(), String.t(), String.t(), Keyword.t()) :: any()
  def random_data(module, file, key, opts \\ []) do
    locale_name =
      opts
      |> Keyword.get(:locale, nil)
      |> Resolver.resolve_locale_config()

    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([@data_path, Atom.to_string(locale_name), module_name, file])

    if File.exists?(file_path) do
      Cache.create_cache(locale_name, module, file)

      persistent_term_key =
        Cache.create_persistent_term_key(Atom.to_string(locale_name), module, file)

      persistent_term_key |> :persistent_term.get() |> Map.get(key) |> Enum.random()
    else
      Cache.create_cache(:default, module, file)
      default_persistent_term_key = Cache.create_persistent_term_key("default", module, file)

      default_persistent_term_key |> :persistent_term.get() |> Map.get(key) |> Enum.random()
    end
  end
end
