defmodule NeoFaker do
  @moduledoc """
  A fake data generator for tests, database seeds, and local development.

  Generators are grouped by domain, one module each, for example `NeoFaker.Person`,
  `NeoFaker.Internet`, and `NeoFaker.Date`. Functions that return a single value are
  named after that value (`NeoFaker.Person.first_name/1`); functions that return several
  values use the plural form and always return a list (`NeoFaker.Lorem.words/2`).

  ## Locales

  Generators backed by a data set accept a `:locale` option. To change the locale for the
  calling process, use `NeoFaker.Locale.set/1`. To set a default for the whole
  application, configure it:

      config :neo_faker, locale: :id_id

  See `NeoFaker.Locale` for how these settings interact.

  ## Reproducible output

  Every generator draws from `:rand`, which the VM seeds per process. Call `seed/1` to
  make the calling process produce the same sequence of values on every run.

  ## Examples

      iex> NeoFaker.Person.full_name()
      "Abigail Bethany Crawford"

      iex> NeoFaker.Person.full_name(locale: :id_id)
      "Siti Nurhaliza Putri"

  """
  @moduledoc since: "0.1.0"

  alias NeoFaker.Locale

  @doc """
  Starts the `:neo_faker` application and validates the configured locale.

  Calling this function is optional: every generator works without it. It is useful in
  `test/test_helper.exs`, where it fails fast on an invalid
  `config :neo_faker, locale: ...` instead of on the first generator call.

  Raises `ArgumentError` if the configured locale is not supported.

  ## Examples

      iex> NeoFaker.start()
      :ok

  """
  @spec start() :: :ok
  def start do
    {:ok, _apps} = Application.ensure_all_started(:neo_faker)
    _locale = Locale.fetch()
    :ok
  end

  @doc """
  Seeds the random number generator of the calling process.

  After seeding, every generator called from the same process returns the same sequence
  of values, which makes failures involving fake data reproducible. Only the calling
  process is affected. `NeoFaker.Crypto.token/2` is the one exception: it always uses
  cryptographically strong random bytes and is therefore never reproducible.

  `seed` is an integer or a three-integer tuple, as accepted by `:rand.seed/2`.

  ## Examples

      iex> NeoFaker.seed(12_345)
      :ok

      iex> NeoFaker.seed({1, 2, 3})
      :ok

  """
  @doc since: "0.15.0"
  @spec seed(integer() | {integer(), integer(), integer()}) :: :ok
  def seed(seed) when is_integer(seed) or (is_tuple(seed) and tuple_size(seed) == 3) do
    _state = :rand.seed(:exsss, seed)
    :ok
  end
end
