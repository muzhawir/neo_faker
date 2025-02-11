defmodule Nf.Helper do
  @moduledoc false

  import Nf.Helper.Utils

  @doc """
  Builds the absolute path to a locale-specific file.

  Given a `locale`, `module`, and `file_name`, this function constructs the
  corresponding file path within the `lib/data/` directory.
  """
  @spec build_locale_path(String.t(), String.t(), String.t()) :: String.t()
  def build_locale_path(locale, module, file_name) do
    Path.join([File.cwd!(), "lib", "data", locale, module, file_name])
  end

  @doc """
  Reads a locale-specific file and returns its content as a map.

  This function determines the appropriate locale from the application
  configuration and attempts to read the specified file. If the file is
  not found for the configured locale, it falls back to the `"default"` locale.
  """
  @spec read_locale_file(String.t(), String.t()) :: map()
  def read_locale_file(module_name, file_name) do
    locale = Application.get_env(:neo_faker, :locale)
    path = build_locale_path(locale, module_name, file_name)

    if File.exists?(path) do
      load_locale_file(path)
    else
      load_locale_file(build_locale_path("default", module_name, file_name))
    end
  end
end
