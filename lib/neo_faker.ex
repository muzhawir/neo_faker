defmodule NeoFaker do
  @moduledoc """
  NeoFaker is a package for generating fake data in Elixir.

  This module provides the main interface for starting the application and seeding the random
  number generator. See `NeoFaker.Locale` for managing locale configuration.

  ## Locale support

  Many modules accept a `:locale` option. Use `NeoFaker.Locale.set/1` to override the locale for
  the calling process, or pass `locale:` per call. To set a locale for the whole application
  instead (e.g. for a Phoenix app), configure `config :neo_faker, locale: ...`, then see
  [Getting Started](https://hexdocs.pm/neo_faker/getting-started.html).

      iex> NeoFaker.Locale.set(:id_id)
      :ok

      iex> NeoFaker.Person.first_name()  # uses :id_id for this process
      "Jaka"

      iex> NeoFaker.Person.first_name(locale: :en_us)  # overrides per call
      "José"

  See the [available locales](https://hexdocs.pm/neo_faker/locales.html) for the full list of
  supported locale codes.
  """
  @moduledoc since: "0.1.0"

  alias NeoFaker.Locale

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
      case Locale.fetch() do
        {:ok, locale} ->
          locale

        :error ->
          Locale.set(:default)
          :default
      end

    IO.puts("\nNeoFaker started with locale: :#{active_locale}")

    :ok
  end

  @doc """
  Returns the current locale, preferring a process-scoped override over the application-wide
  default.

  ## Examples

      iex> NeoFaker.locale()
      {:ok, :en_us}

  """
  @deprecated "Use NeoFaker.Locale.fetch/0 instead"
  @spec locale() :: {:ok, atom()} | :error
  def locale, do: Locale.fetch()

  @doc """
  Sets the locale for the calling process.

  ## Examples

      iex> NeoFaker.set_locale(:id_id)
      :ok

  """
  @deprecated "Use NeoFaker.Locale.set/1 instead"
  @spec set_locale(atom()) :: :ok
  def set_locale(locale), do: Locale.set(locale)

  @doc """
  Returns the active locale, falling back to `:default` when none is set.

  ## Examples

      iex> NeoFaker.get_locale()
      :en_us

  """
  @deprecated "Use NeoFaker.Locale.get/0 instead"
  @spec get_locale() :: atom()
  def get_locale, do: Locale.get()

  @doc """
  Seeds the random number generator for the calling process, for reproducible output.

  NeoFaker draws values via `Enum.random/1` and `:rand.uniform/1`, both backed by `:rand`, which
  OTP already seeds automatically and unpredictably per process. Call this at the start of a
  test (or anywhere else you need deterministic fake data) to pin that seed instead.

  ## Examples

      iex> NeoFaker.seed(12_345)
      :ok

      iex> NeoFaker.seed({1, 2, 3})
      :ok

  """
  @doc since: "0.15.0"
  @spec seed(integer() | {integer(), integer(), integer()}) :: :ok
  def seed(seed_value) when is_integer(seed_value) or tuple_size(seed_value) == 3 do
    :rand.seed(:exsplus, seed_value)
    :ok
  end
end
