defmodule NeoFaker.Locale.Resolver do
  @moduledoc false

  alias NeoFaker.Locale.Disk

  @data_path Path.join([File.cwd!(), "lib", "data"])
  @locale_file Path.join([@data_path, "locale.exs"])

  @doc """
  Resolves the locale configuration based on the given options.
  """
  def resolve_locale_config(opts) do
    if is_nil(opts) do
      :neo_faker
      |> Application.get_env(:locale)
      |> resolve_locale()
    else
      resolve_locale(opts)
    end
  end

  @doc """
  Resolves a locale based on the given locale.
  """
  @spec resolve_locale(atom()) :: atom()
  def resolve_locale(locale) do
    if locale_exists?(locale) do
      locale
    else
      :default
    end
  end

  @doc """
  Checks if a locale exists in the locale.exs file.
  """
  @spec locale_exists?(atom()) :: boolean()
  def locale_exists?(locale) do
    if is_nil(:persistent_term.get(:available_locales, nil)) do
      :persistent_term.put(:available_locales, MapSet.new(Disk.evaluate_file!(@locale_file)))

      :available_locales |> :persistent_term.get() |> MapSet.member?(Atom.to_string(locale))
    else
      :available_locales |> :persistent_term.get() |> MapSet.member?(Atom.to_string(locale))
    end
  end
end
