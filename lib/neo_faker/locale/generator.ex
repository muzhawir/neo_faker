defmodule NeoFaker.Locale.Generator do
  @moduledoc false

  alias NeoFaker.Locale.Disk
  alias NeoFaker.Locale.Resolver

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
  @spec random(atom(), String.t(), String.t(), Keyword.t()) :: any()
  def random(module, file, key, opts \\ []) do
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    locale = Resolver.resolve_locale_config(opts)
    file_path = Path.join([@data_path, locale, module_name, file])

    if File.exists?(file_path) do
      file_path |> Disk.evaluate_file!() |> Map.get(key) |> Enum.random()
    else
      [@data_path, "default", module_name, file]
      |> Path.join()
      |> Disk.evaluate_file!()
      |> Map.get(key)
      |> Enum.random()
    end
  end
end
