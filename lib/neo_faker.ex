defmodule NeoFaker do
  @moduledoc """
  NeoFaker is a package for generating fake data in Elixir.

  This module provides the main interface for starting the application and
  managing locale configuration.

  ## Locale support

  Many modules accept a `:locale` option. Use `set_locale/1` to override the
  locale for the calling process, or pass `locale:` per call. To set a locale
  for the whole application instead (e.g. for a Phoenix app), configure
  `config :neo_faker, locale: ...` — see
  [Getting Started](https://hexdocs.pm/neo_faker/getting-started.html).

      iex> NeoFaker.set_locale(:id_id)
      :ok

      iex> NeoFaker.Person.first_name()  # uses :id_id for this process
      "Jaka"

      iex> NeoFaker.Person.first_name(locale: :en_us)  # overrides per call
      "José"

  See the [available locales](https://hexdocs.pm/neo_faker/locales.html)
  for the full list of supported locale codes.
  """
  @moduledoc since: "0.1.0"

  alias NeoFaker.Data

  @locale_key {__MODULE__, :locale}

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
  Returns the current locale, preferring a process-scoped override over the
  application-wide default.

  Checks, in order: a locale set for the calling process via `set_locale/1`,
  then `config :neo_faker, locale: ...`. Returns `{:ok, locale}` when either
  source has a value, or `:error` when neither does. Raises `ArgumentError` if
  the application-configured value is not an atom, or is an unsupported atom
  (i.e. not `:default` and not in `NeoFaker.Data.supported_locales/0`) — this
  can happen if `config :neo_faker, locale: ...` is set directly instead of
  going through `set_locale/1`, which validates before storing.

  ## Examples

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.locale()
      {:ok, :en_us}

  """
  @spec locale() :: {:ok, atom()} | :error
  def locale do
    case Process.get(@locale_key) do
      nil -> locale_from_application_env()
      locale -> {:ok, locale}
    end
  end

  @spec locale_from_application_env() :: {:ok, atom()} | :error
  defp locale_from_application_env do
    case Application.get_env(:neo_faker, :locale) do
      nil ->
        :error

      :default ->
        {:ok, :default}

      locale when is_atom(locale) ->
        if Data.locale_available?(locale) do
          {:ok, locale}
        else
          supported =
            [:default | Data.supported_locales()]
            |> Enum.sort()
            |> inspect()

          raise ArgumentError,
                "Unsupported locale #{inspect(locale)}. Expected :default or one of #{supported} " <>
                  "or see the available locales documentation."
        end

      invalid ->
        raise ArgumentError,
              "Invalid locale format. Expected atom, got: #{inspect(invalid)}"
    end
  end

  @doc """
  Sets the locale for the calling process.

  The override is process-scoped (stored in the process dictionary), so
  concurrent processes — including `async: true` ExUnit tests — never
  interfere with each other. It does not touch `config :neo_faker, locale:
  ...`, which remains the fallback for any process that hasn't called this
  function. See the [available locales](https://hexdocs.pm/neo_faker/locales.html)
  for the full list of supported codes. Raises `ArgumentError` if a non-atom
  or unsupported locale is provided.

  ## Examples

      iex> NeoFaker.set_locale(:id_id)
      :ok

      iex> NeoFaker.set_locale(:en_us)
      :ok

      iex> NeoFaker.set_locale(:default)
      :ok

      iex> NeoFaker.set_locale(:bogus)
      ** (ArgumentError) Unsupported locale :bogus. Expected one of [:default, :en_us, :id_id] or see the available locales documentation.

  The list of supported locales in the error message is generated dynamically
  from `priv/data/locale.exs`, so it will always reflect the actual supported
  locales (including any added in future releases).

  """
  @spec set_locale(atom()) :: :ok
  def set_locale(locale) when is_atom(locale) do
    if locale == :default or Data.locale_available?(locale) do
      Process.put(@locale_key, locale)
      :ok
    else
      supported =
        [:default | Data.supported_locales()]
        |> Enum.sort()
        |> inspect()

      raise ArgumentError,
            "Unsupported locale #{inspect(locale)}. Expected one of #{supported} " <>
              "or see the available locales documentation."
    end
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

  """
  @spec get_locale() :: atom()
  def get_locale do
    case locale() do
      {:ok, locale} -> locale
      :error -> :default
    end
  end

  @doc """
  Seeds the random number generator for the calling process, for reproducible
  output.

  NeoFaker draws values via `Enum.random/1` and `:rand.uniform/1`, both backed
  by `:rand`, which OTP already seeds automatically and unpredictably per
  process. Call this at the start of a test (or anywhere else you need
  deterministic fake data) to pin that seed instead.

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
