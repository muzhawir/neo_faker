defmodule NeoFaker do
  @moduledoc false

  @doc """
  Starts the NeoFaker application and ensures a locale is set.

  If no locale is configured in the application environment, sets the locale to `:default`.
  Prints the active locale and returns `:ok`.
  """
  def start do
    Application.ensure_started(:neo_faker)

    case_result =
      case locale() do
        :error -> set_locale(:default)
        _ -> locale()
      end

    IO.puts("\nNeoFaker started with locale: :#{case_result}")

    :ok
  end

  @doc """
  Returns the current locale set for the NeoFaker application.

  If no locale is configured in the application environment, returns `:error`.

  ## Examples

      iex> NeoFaker.locale()
      :default

  """
  def locale do
    case Application.get_env(:neo_faker, :locale) do
      nil -> :error
      locale -> locale
    end
  end

  @doc """
  Sets the current locale.

  Set the locale to a specific language and country code, you can find the available locales
  at: https://hexdocs.pm/neo_faker/available-locales.html

  ## Examples

      iex> NeoFaker.set_locale(:id_id)
      :ok

  """
  @spec set_locale(atom()) :: :ok
  def set_locale(locale \\ :default), do: Application.put_env(:neo_faker, :locale, locale)
end
