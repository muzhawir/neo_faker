defmodule Nf.Helper do
  @moduledoc """
  This module provides helper functions commonly used across other modules.
  """
  @moduledoc since: "0.4.1"

  @doc """
  Helper function for build locale path.
  """
  @spec build_locale_path(String.t(), String.t(), String.t()) :: String.t()
  def build_locale_path(locale, module, file_name) do
    Path.join([File.cwd!(), "lib", "data", locale, module, file_name])
  end

  def load_locale_file(path), do: path |> Code.eval_file() |> elem(0)

  @doc """
  Reads a locale file and returns its contents as a map.

  If the specified locale file does not exist, it falls back to the default locale.
  """
  @spec read_locale_file(String.t(), String.t()) :: map()
  def read_locale_file(module, file_name) do
    locale = Application.get_env(:neo_faker, :locale)
    path = build_locale_path(locale, module, file_name)

    if File.exists?(path) do
      load_locale_file(path)
    else
      load_locale_file(build_locale_path("default", module, file_name))
    end
  end
end
