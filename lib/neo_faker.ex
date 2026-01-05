defmodule NeoFaker do
  @moduledoc """
  NeoFaker is a library for generating fake data in Elixir.

  This module provides the main interface for starting the application and
  managing locale configuration.
  """
  @moduledoc since: "0.1.0"

  alias NeoFaker.Helpers.Constants

  @doc """
  Starts the NeoFaker application and ensures a locale is set.

  If no locale is configured in the application environment, sets the locale to
  the default locale. Prints the active locale and returns `:ok`.

  ## Examples

      iex> NeoFaker.start()
      :ok

  """
  @spec start() :: :ok
  def start do
    Application.ensure_started(:neo_faker)

    active_locale =
      case locale() do
        {:ok, locale} ->
          locale

        :error ->
          set_locale(Constants.default_locale())
          Constants.default_locale()
      end

    IO.puts("\nNeoFaker started with locale: :#{active_locale}")

    :ok
  end

  @doc """
  Returns the current locale set for the NeoFaker application.

  If no locale is configured in the application environment, returns `:error`.

  ## Examples

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.locale()
      {:ok, :en_us}

      iex> Application.delete_env(:neo_faker, :locale)
      iex> NeoFaker.locale()
      :error

  """
  @spec locale() :: {:ok, atom()} | :error
  def locale do
    case Application.get_env(:neo_faker, :locale) do
      nil ->
        :error

      locale when is_atom(locale) ->
        {:ok, locale}

      invalid ->
        raise ArgumentError,
              "Invalid locale format. Expected atom, got: #{inspect(invalid)}"
    end
  end

  @doc """
  Sets the current locale for the NeoFaker application.

  Set the locale to a specific language and country code. You can find the
  available locales at: https://hexdocs.pm/neo_faker/available-locales.html

  The locale must be an atom. Raises `ArgumentError` if a non-atom value is provided.

  ## Examples

      iex> NeoFaker.set_locale(:id_id)
      :ok

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.set_locale(:default)
      :ok

  """
  @spec set_locale(atom()) :: :ok
  def set_locale(locale) when is_atom(locale) do
    Application.put_env(:neo_faker, :locale, locale)
    :ok
  end

  def set_locale(invalid) do
    raise ArgumentError, "Locale must be an atom. Got: #{inspect(invalid)}"
  end

  @doc """
  Returns the current locale or the default locale if none is set.

  This is a convenience function that always returns a locale value,
  defaulting to `:default` if no locale has been configured.

  ## Examples

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.get_locale()
      :en_us

      iex> Application.delete_env(:neo_faker, :locale)
      iex> NeoFaker.get_locale()
      :default

  """
  @spec get_locale() :: atom()
  def get_locale do
    case locale() do
      {:ok, locale} -> locale
      :error -> Constants.default_locale()
    end
  end
end
