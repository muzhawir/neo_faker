defmodule NeoFaker.Locale do
  @moduledoc """
  Functions for managing and inspecting the active locale.

  A locale selects which data set a generator draws from, for example Indonesian names
  instead of US English ones. This module is the single owner of locale state and of the
  list of supported locale codes.

  ## Resolution order

  The locale used by a generator call is resolved in this order:

    1. The `:locale` option passed to that call, e.g. `NeoFaker.Person.first_name(locale: :id_id)`.
    2. The locale set for the calling process with `set/1`.
    3. The application-wide default from `config :neo_faker, locale: ...`.
    4. `:default`, the baseline US English data set.

  Because `set/1` stores its value in the process dictionary, it never leaks into other
  processes. This makes it safe to use in `async: true` tests.

  ## The `:default` locale

  `:default` is not a regional locale. It names the baseline data set under
  `priv/data/default/`, which every locale falls back to for any data file it does not
  ship itself. `:en_us`, for instance, ships no data files of its own, so it reads
  `:default` data everywhere.

  ## Examples

      iex> NeoFaker.Locale.set(:id_id)
      :ok

      iex> NeoFaker.Person.first_name()
      "Jaka"

      iex> NeoFaker.Person.first_name(locale: :en_us)
      "José"

  See the [Locales guide](locales.html) for the full list of supported locale codes.
  """
  @moduledoc since: "0.15.0"

  @locale_key {__MODULE__, :locale}

  # `:default` is deliberately absent: it is the baseline data set under
  # `priv/data/default/`, not a locale a user selects. Keep this list sorted.
  # Adding a locale also means adding `priv/data/<code>/` data files, so the
  # supported set only ever changes alongside a code change anyway.
  @supported_locales ~w(en_us id_id)a

  @typedoc """
  A locale code: `:default` or one of the codes returned by `supported/0`.
  """
  @type t :: atom()

  @doc """
  Returns the locale for the calling process, or `:error` if none is configured.

  Checks, in order, a locale set for the calling process via `set/1`, then
  `config :neo_faker, locale: ...`.

  Raises `ArgumentError` if the configured application value is not `:default` or a
  supported locale. `set/1` validates its argument, but `config :neo_faker, locale: ...`
  is only read, and therefore only validated, here.

  ## Examples

      iex> NeoFaker.Locale.set(:en_us)
      :ok
      iex> NeoFaker.Locale.fetch()
      {:ok, :en_us}

  """
  @spec fetch() :: {:ok, t()} | :error
  def fetch do
    case Process.get(@locale_key) do
      nil -> fetch_from_application_env()
      locale -> {:ok, locale}
    end
  end

  @doc """
  Returns the locale for the calling process, falling back to `:default`.

  Unlike `fetch/0`, this function always returns a locale.

  ## Examples

      iex> NeoFaker.Locale.set(:en_us)
      :ok
      iex> NeoFaker.Locale.get()
      :en_us

  """
  @spec get() :: t()
  def get do
    case fetch() do
      {:ok, locale} -> locale
      :error -> :default
    end
  end

  @doc """
  Sets the locale for the calling process.

  The value is stored in the process dictionary, so it only affects the calling process
  and never interferes with concurrent processes. It does not change
  `config :neo_faker, locale: ...`, which remains the fallback for every process that has
  not called this function.

  Raises `ArgumentError` if `locale` is not `:default` or a supported locale.

  ## Examples

      iex> NeoFaker.Locale.set(:id_id)
      :ok

      iex> NeoFaker.Locale.set(:default)
      :ok

      iex> NeoFaker.Locale.set(:bogus)
      ** (ArgumentError) unsupported locale :bogus, expected one of [:default, :en_us, :id_id]. See the available locales documentation

  """
  @spec set(t()) :: :ok
  def set(locale) do
    Process.put(@locale_key, validate!(locale))
    :ok
  end

  @doc """
  Returns the list of supported locale codes, sorted.

  The `:default` data set is not included; see the module documentation.

  ## Examples

      iex> NeoFaker.Locale.supported()
      [:en_us, :id_id]

  """
  @spec supported() :: [t()]
  def supported, do: @supported_locales

  @doc """
  Returns `true` if `locale` is one of the codes returned by `supported/0`.

  Returns `false` for `:default`, which is a data set rather than a locale.

  ## Examples

      iex> NeoFaker.Locale.available?(:id_id)
      true

      iex> NeoFaker.Locale.available?(:bogus)
      false

  """
  @spec available?(term()) :: boolean()
  def available?(locale), do: locale in @supported_locales

  @doc false
  # Validates a locale code and returns it, raising `ArgumentError` otherwise.
  # Shared by `set/1`, the application-env check, and `NeoFaker.Data`, which
  # interpolates the locale into a file path and must never see anything else.
  @spec validate!(term()) :: t()
  def validate!(:default), do: :default

  def validate!(locale) when is_atom(locale) do
    if available?(locale) do
      locale
    else
      raise ArgumentError, unsupported_message(locale)
    end
  end

  def validate!(locale) do
    raise ArgumentError, "locale must be an atom, got: #{inspect(locale)}"
  end

  @doc false
  # NimbleOptions `{:custom, ...}` validator for the per-call `:locale` option.
  # `nil` (the schema default) means "use the active locale".
  @spec validate_option(term()) :: {:ok, t() | nil} | {:error, String.t()}
  def validate_option(nil), do: {:ok, nil}
  def validate_option(:default), do: {:ok, :default}

  def validate_option(locale) when is_atom(locale) do
    if available?(locale), do: {:ok, locale}, else: {:error, unsupported_message(locale)}
  end

  def validate_option(locale) do
    {:error, "expected a locale atom, got: #{inspect(locale)}"}
  end

  defp fetch_from_application_env do
    case Application.get_env(:neo_faker, :locale) do
      nil -> :error
      locale -> {:ok, validate!(locale)}
    end
  end

  defp unsupported_message(locale) do
    expected = [:default | @supported_locales] |> Enum.sort() |> inspect()

    "unsupported locale #{inspect(locale)}, expected one of #{expected}. " <>
      "See the available locales documentation"
  end
end
