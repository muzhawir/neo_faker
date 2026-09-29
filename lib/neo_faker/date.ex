defmodule NeoFaker.Date do
  @moduledoc """
  Functions for generating random dates.

  Every function returns a `Date` struct; use `Date.to_iso8601/1` if you need a string.
  "Today" means the current date in the local time zone of the host, as returned by
  `today/0`.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Date.Generator
  alias NeoFaker.Date.Validator, as: DateValidator
  alias NeoFaker.Helpers.Validator

  @doc """
  Generates a random date offset from today by a number of days drawn from `range`.

  `range` defaults to `-365..365`, a date within a year of today. Negative offsets are in
  the past and positive offsets are in the future.

  Raises `ArgumentError` if `range` is not a non-empty range.

  ## Examples

      iex> NeoFaker.Date.add()
      ~D[2025-03-25]

      iex> NeoFaker.Date.add(0..31)
      ~D[2025-03-30]

  """
  @spec add(Range.t()) :: Date.t()
  def add(range \\ -365..365) do
    range
    |> Validator.validate_range!("range")
    |> Generator.add()
  end

  @doc """
  Generates a random date between `start` and `finish`, inclusive.

  `start` defaults to the Unix epoch, `~D[1970-01-01]`, and `finish` defaults to today.

  Raises `ArgumentError` if either argument is not a `Date`, or if `start` is after
  `finish`.

  ## Examples

      iex> NeoFaker.Date.between()
      ~D[1994-06-13]

      iex> NeoFaker.Date.between(~D[2020-01-01], ~D[2025-01-01])
      ~D[2022-08-17]

  """
  @spec between(Date.t(), Date.t()) :: Date.t()
  def between(start \\ ~D[1970-01-01], finish \\ today()) do
    DateValidator.validate_date_order!(start, finish)
    Generator.between(start, finish)
  end

  @doc """
  Generates a random birthday for a person aged between `min_age` and `max_age`, inclusive.

  Ages are in whole years as of today. `min_age` defaults to `18` and `max_age` defaults
  to `65`.

  Raises `ArgumentError` if either age is not a non-negative integer, or if `min_age` is
  greater than `max_age`.

  ## Examples

      iex> NeoFaker.Date.birthday()
      ~D[1997-01-02]

      iex> NeoFaker.Date.birthday(0, 12)
      ~D[2018-03-04]

  """
  @doc since: "0.10.0"
  @spec birthday(non_neg_integer(), non_neg_integer()) :: Date.t()
  def birthday(min_age \\ 18, max_age \\ 65) do
    Validator.validate_non_neg_bounds!(min_age, max_age, {"min_age", "max_age"})

    today = today()

    # The oldest person turns `max_age + 1` tomorrow; the youngest turned
    # `min_age` today.
    oldest = today |> Date.shift(year: -(max_age + 1)) |> Date.add(1)
    youngest = Date.shift(today, year: -min_age)

    Generator.between(oldest, youngest)
  end

  @doc """
  Generates a random date between `days` days ago and today, inclusive.

  `days` defaults to `365`. Equivalent to `add(-days..0)`.

  Raises `ArgumentError` if `days` is not a positive integer.

  ## Examples

      iex> NeoFaker.Date.past(30)
      ~D[2025-02-25]

  """
  @spec past(pos_integer()) :: Date.t()
  def past(days \\ 365)
  def past(days) when is_integer(days) and days > 0, do: Generator.add(-days..0//1)
  def past(days), do: raise_days!(days)

  @doc """
  Generates a random date between today and `days` days from now, inclusive.

  `days` defaults to `365`. Equivalent to `add(0..days)`.

  Raises `ArgumentError` if `days` is not a positive integer.

  ## Examples

      iex> NeoFaker.Date.future(30)
      ~D[2025-04-24]

  """
  @spec future(pos_integer()) :: Date.t()
  def future(days \\ 365)
  def future(days) when is_integer(days) and days > 0, do: Generator.add(0..days//1)
  def future(days), do: raise_days!(days)

  @doc """
  Returns today's date in the local time zone of the host.

  This function is not random. It is the reference point for every other function in
  this module.

  ## Examples

      iex> NeoFaker.Date.today()
      ~D[2025-03-25]

  """
  @spec today() :: Date.t()
  def today, do: Generator.local_date_now()

  defp raise_days!(days) do
    raise ArgumentError, "days must be a positive integer, got: #{inspect(days)}"
  end
end
