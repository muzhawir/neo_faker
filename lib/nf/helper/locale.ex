defmodule Nf.Helper.Locale do
  @moduledoc false

  @base_data_path Path.join([File.cwd!(), "lib", "data"])

  @doc """
  Reads and returns the content of a locale file as a map.

  If the file does not exist for the configured locale, it falls back to the `"default"` locale.
  """
  @spec read_locale_file(String.t(), String.t()) :: map()
  def read_locale_file(module, file) do
    locale_setting = Application.get_env(:neo_faker, :locale)
    locale_path = build_locale_path(locale_setting, module, file)

    if File.exists?(locale_path) do
      locale_path |> Code.eval_file() |> elem(0)
    else
      "default" |> build_locale_path(module, file) |> Code.eval_file() |> elem(0)
    end
  end

  @doc """
  Constructs the absolute file path for a locale-specific data file.
  """
  @spec build_locale_path(String.t(), String.t(), String.t()) :: String.t()
  def build_locale_path(locale, module, file_name) do
    Path.join([@base_data_path, locale, module, file_name])
  end
end
