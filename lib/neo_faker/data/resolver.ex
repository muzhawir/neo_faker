defmodule NeoFaker.Data.Resolver do
  @moduledoc false

  alias NeoFaker.Data.Disk

  @locale_file Path.join([File.cwd!(), "priv", "data", "locale.exs"])

  @doc """
  Resolves the locale to use, falling back to config or :default.
  """
  @spec resolve_locale_config(nil | atom()) :: atom()
  def resolve_locale_config(nil) do
    :neo_faker |> Application.get_env(:locale) |> resolve_locale()
  end

  def resolve_locale_config(locale), do: resolve_locale(locale)

  @doc """
  Returns the locale if available, otherwise :default.
  """
  @spec resolve_locale(atom()) :: atom()
  def resolve_locale(locale), do: if(locale_available?(locale), do: locale, else: :default)

  @doc """
  Checks if a locale is available in the locale.exs file.
  """
  @spec locale_available?(atom()) :: boolean()
  def locale_available?(locale) do
    available_locales =
      case :persistent_term.get(:available_locales, nil) do
        nil ->
          locales = @locale_file |> Disk.fetch_file!() |> MapSet.new()

          :persistent_term.put(:available_locales, locales)

          locales

        locales ->
          locales
      end

    MapSet.member?(available_locales, Atom.to_string(locale))
  end
end
