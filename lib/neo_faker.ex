defmodule NeoFaker do
  @moduledoc false

  @doc """
  Start NeoFaker
  """
  @spec start() :: :ok
  def start do
    Application.ensure_started(:neo_faker)

    case_result =
      case locale() do
        :error -> set_locale(:default)
        _ -> locale()
      end

    IO.puts("NeoFaker started with locale: :#{case_result}")

    :ok
  end

  @doc """
  Returns the current locale.
  """
  @spec locale() :: atom()
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
