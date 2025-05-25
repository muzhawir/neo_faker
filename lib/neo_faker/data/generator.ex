defmodule NeoFaker.Data.Generator do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Disk
  alias NeoFaker.Data.Resolver

  @doc """
  Returns a random value from the specified locale data file.

  ## Parameters

    - `module`: The module where the locale data is stored.
    - `file`: The data file name (e.g., "author.exs").
    - `key`: The key within the data file (e.g., "first_names").
    - `opts`: Keyword options. Supports `:locale`.

  If the locale or file does not exist, falls back to the default locale.
  """
  @spec random_value(atom(), String.t(), String.t(), Keyword.t()) :: any()
  def random_value(module, file, key, opts \\ []) do
    locale = Resolver.resolve_locale_config(opts[:locale])
    resolved_locale = ensure_locale_file_exists(locale, module, file)
    data = Cache.fetch!(resolved_locale, module, file)

    data |> Map.fetch!(key) |> Enum.random()
  end

  defp ensure_locale_file_exists(locale, module, file) do
    module_name = module |> Module.split() |> List.last() |> String.downcase()
    file_path = Path.join([Disk.data_path(), Atom.to_string(locale), module_name, file])

    if File.exists?(file_path) do
      locale
    else
      :default
    end
  end
end
