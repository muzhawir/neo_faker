defmodule NeoFaker.Locale do
  @moduledoc """
  Functions for managing and inspecting the active locale.

  This is the single owner of locale state and the list of supported locale
  codes. Every other module (including `NeoFaker.Data`) reads locale state
  through this module rather than managing it independently.

  ## Locale support

  Many modules accept a `:locale` option. Use `set/1` to override the locale
  for the calling process, or pass `locale:` per call. To set a locale for
  the whole application instead (e.g. for a Phoenix app), configure
  `config :neo_faker, locale: ...`, then see
  [Getting Started](https://hexdocs.pm/neo_faker/getting-started.html).

      iex> NeoFaker.Locale.set(:id_id)
      :ok

      iex> NeoFaker.Person.first_name()  # uses :id_id for this process
      "Jaka"

      iex> NeoFaker.Person.first_name(locale: :en_us)  # overrides per call
      "José"

  See the [available locales](https://hexdocs.pm/neo_faker/locales.html)
  for the full list of supported locale codes.
  """
  @moduledoc since: "0.15.0"

  @locale_key {__MODULE__, :locale}
  @locale_file Path.join([:neo_faker |> :code.priv_dir() |> to_string(), "data", "locale.exs"])

  @doc """
  Returns the current locale, preferring a process-scoped override over the
  application-wide default.

  Checks, in order: a locale set for the calling process via `set/1`, then
  `config :neo_faker, locale: ...`. Returns `{:ok, locale}` when either
  source has a value, or `:error` when neither does. Raises `ArgumentError` if
  the application-configured value is not an atom, or is an unsupported atom
  (i.e. not `:default` and not in `supported/0`), which can happen if
  `config :neo_faker, locale: ...` is set directly instead of going through
  `set/1`, which validates before storing.

  ## Examples

      iex> NeoFaker.Locale.set(:en_us)
      :ok

      iex> NeoFaker.Locale.fetch()
      {:ok, :en_us}

  """
  @spec fetch() :: {:ok, atom()} | :error
  def fetch do
    case Process.get(@locale_key) do
      nil -> fetch_from_application_env()
      locale -> {:ok, locale}
    end
  end

  @spec fetch_from_application_env() :: {:ok, atom()} | :error
  defp fetch_from_application_env do
    case Application.get_env(:neo_faker, :locale) do
      nil ->
        :error

      :default ->
        {:ok, :default}

      locale when is_atom(locale) ->
        if available?(locale) do
          {:ok, locale}
        else
          raise ArgumentError,
                "Unsupported locale #{inspect(locale)}. Expected :default or one of #{supported_and_default()} " <>
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
  concurrent processes, including `async: true` ExUnit tests, never
  interfere with each other. It does not touch `config :neo_faker, locale:
  ...`, which remains the fallback for any process that hasn't called this
  function. See the [available locales](https://hexdocs.pm/neo_faker/locales.html)
  for the full list of supported codes. Raises `ArgumentError` if a non-atom
  or unsupported locale is provided.

  ## Examples

      iex> NeoFaker.Locale.set(:id_id)
      :ok

      iex> NeoFaker.Locale.set(:en_us)
      :ok

      iex> NeoFaker.Locale.set(:default)
      :ok

      iex> NeoFaker.Locale.set(:bogus)
      ** (ArgumentError) Unsupported locale :bogus. Expected one of [:default, :en_us, :id_id] or see the available locales documentation.

  The list of supported locales in the error message is generated dynamically
  from `priv/data/locale.exs`, so it will always reflect the actual supported
  locales (including any added in future releases).

  """
  @spec set(atom()) :: :ok
  def set(locale) when is_atom(locale) do
    if locale == :default or available?(locale) do
      Process.put(@locale_key, locale)
      :ok
    else
      raise ArgumentError,
            "Unsupported locale #{inspect(locale)}. Expected one of #{supported_and_default()} " <>
              "or see the available locales documentation."
    end
  end

  def set(invalid) do
    raise ArgumentError, "Locale must be an atom. Got: #{inspect(invalid)}"
  end

  @doc """
  Returns the active locale, falling back to `:default` when none is set.

  Unlike `fetch/0`, this function always returns an atom and never returns
  `:error`, making it convenient for use inside generator functions.

  ## Examples

      iex> NeoFaker.Locale.set(:en_us)
      :ok

      iex> NeoFaker.Locale.get()
      :en_us

  """
  @spec get() :: atom()
  def get do
    case fetch() do
      {:ok, locale} -> locale
      :error -> :default
    end
  end

  @doc """
  Returns the sorted list of all supported locale atoms from `priv/data/locale.exs`.

  The `:default` sentinel is **not** included; use `available?/1` or check
  for `:default` explicitly. Results are cached in `:persistent_term` after
  the first call, so repeated invocations are O(1).

  ## Examples

      iex> NeoFaker.Locale.supported()
      [:en_us, :id_id]

  """
  @spec supported() :: [atom()]
  def supported do
    load_locale_set() |> Enum.map(&String.to_atom/1) |> Enum.sort()
  end

  @doc """
  Returns `true` when `locale` is listed in `priv/data/locale.exs`, `false`
  otherwise.

  The result of reading `locale.exs` is cached in `:persistent_term` on the
  first call, so subsequent calls are O(1) lookups.

  ## Examples

      iex> NeoFaker.Locale.available?(:id_id)
      true

      iex> NeoFaker.Locale.available?(:bogus)
      false

  """
  @spec available?(atom()) :: boolean()
  def available?(locale) do
    MapSet.member?(load_locale_set(), Atom.to_string(locale))
  end

  @spec supported_and_default() :: String.t()
  defp supported_and_default, do: [:default | supported()] |> Enum.sort() |> inspect()

  # Loads (or retrieves from cache) the MapSet of locale strings from locale.exs.
  @spec load_locale_set() :: MapSet.t(String.t())
  defp load_locale_set do
    key = {__MODULE__, :available_locales}

    case :persistent_term.get(key, nil) do
      nil ->
        loaded = @locale_file |> read_data_file!() |> MapSet.new()
        :persistent_term.put(key, loaded)
        loaded

      loaded ->
        loaded
    end
  end

  @spec read_data_file!(String.t()) :: any()
  defp read_data_file!(path) do
    path |> File.read!() |> Code.eval_string([], __ENV__) |> elem(0)
  end
end
