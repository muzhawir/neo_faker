defmodule NeoFaker.Data.Resolver do
  @moduledoc false

  alias NeoFaker.Data.Disk

  @locale_file Path.join([File.cwd!(), "priv", "data", "locale.exs"])

  @doc """
  Resolves the locale configuration based on the provided options.
  """
  def resolve_locale_config(options) do
    if is_nil(options) do
      :neo_faker |> Application.get_env(:locale) |> resolve_locale()
    else
      resolve_locale(options)
    end
  end

  @doc """
  Resolves a locale based on the provided locale.
  """
  @spec resolve_locale(atom()) :: atom()
  def resolve_locale(locale) do
    if locale_available?(locale), do: locale, else: :default
  end

  @doc """
  Checks if a locale is available in the locale.exs file.
  """
  @spec locale_available?(atom()) :: boolean()
  def locale_available?(locale) do
    if is_nil(:persistent_term.get(:available_locales, nil)) do
      available_locales = @locale_file |> Disk.evaluate_file!() |> MapSet.new()

      :persistent_term.put(:available_locales, available_locales)
    end

    :available_locales |> :persistent_term.get() |> MapSet.member?(Atom.to_string(locale))
  end
end
