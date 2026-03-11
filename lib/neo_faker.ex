defmodule NeoFaker do
  @moduledoc """
  NeoFaker is a package for generating fake data in Elixir.

  This module provides the main interface for starting the application and
  managing locale configuration.

  ## Locale support

  Many modules accept a `:locale` option. Use `set_locale/1` to configure a
  default locale for the whole application, or pass `locale:` per call.

      iex> NeoFaker.set_locale(:id_id)
      :ok

      iex> NeoFaker.Person.first_name()  # uses :id_id globally
      "Jaka"

      iex> NeoFaker.Person.first_name(locale: :en_us)  # overrides per call
      "Julia"

  See the [available locales](https://hexdocs.pm/neo_faker/available-locales.html)
  for the full list of supported locale codes.
  """
  @moduledoc since: "0.1.0"

  @doc """
  Starts the NeoFaker application and ensures a locale is configured.

  If no locale is set in the application environment, it defaults to `:default`.
  Prints the active locale to stdout and returns `:ok`.

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
          set_locale(:default)
          :default
      end

    IO.puts("\nNeoFaker started with locale: :#{active_locale}")

    :ok
  end

  @doc """
  Returns the current locale configured for the NeoFaker application.

  Returns `{:ok, locale}` when a locale is set, or `:error` when none has been
  configured. Raises `ArgumentError` if the stored value is not an atom.

  ## Examples

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.locale()
      {:ok, :en_us}

      iex> Application.delete_env(:neo_faker, :locale)
      :ok

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
  Sets the locale for the NeoFaker application.

  The `locale` must be an atom matching a supported locale code (e.g. `:en_us`,
  `:id_id`, `:default`). See the
  [available locales](https://hexdocs.pm/neo_faker/available-locales.html) for
  the full list. Raises `ArgumentError` if a non-atom value is provided.

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
  Returns the active locale, falling back to `:default` when none is set.

  Unlike `locale/0`, this function always returns an atom and never returns
  `:error`, making it convenient for use inside generator functions.

  ## Examples

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.get_locale()
      :en_us

      iex> Application.delete_env(:neo_faker, :locale)
      :ok

      iex> NeoFaker.get_locale()
      :default

  """
  @spec get_locale() :: atom()
  def get_locale do
    case locale() do
      {:ok, locale} -> locale
      :error -> :default
    end
  end
end
