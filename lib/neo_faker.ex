defmodule NeoFaker do
  @moduledoc false

  @doc """
  Returns the current locale.
  """
  @spec locale() :: String.t()
  def locale, do: Application.get_env(:neo_faker, :locale)

  @doc """
  Sets the current locale.

  Set the locale to a specific language and country code, you can find the available locales
  at: https://hexdocs.pm/neo_faker/available-locales.html

  ## Examples

      iex> NeoFaker.set_locale(:id_id)
      :ok

  """
  @spec set_locale(atom()) :: :ok
  def set_locale(locale) when is_atom(locale) do
    Application.put_env(:neo_faker, :locale, locale)
  end
end
