defmodule NeoFaker.Date do
  @moduledoc """
  Functions for generating random dates.

  Provides utilities to generate random dates, including dates relative to today,
  dates within a custom range, birthdays, and past and future dates. Every function
  returns a `Date` struct; call `Date.to_iso8601/1` yourself if you need a string.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Date.Generator
  alias NeoFaker.Date.Validator

  @epoch_date ~D[1970-01-01]
  @date_range -365..365
  @min_age 18
  @max_age 65

  @doc """
  Generates a random date within a specified range relative to today.

  By default, returns a date between 365 days before and 365 days after the current date.
  `range` specifies the number of days to add or subtract from today.

  ## Examples

      iex> NeoFaker.Date.add()
      ~D[2025-03-25]

      iex> NeoFaker.Date.add(0..31)
      ~D[2025-03-30]

  """
  @spec add(Range.t()) :: Date.t()
  def add(range \\ @date_range) do
    Validator.validate_range!(range)

    Generator.add(range)
  end

  @doc """
  Generates a random date between two given dates.

  Both `start` and `finish` are inclusive. Defaults to a date between the Unix
  epoch (`~D[1970-01-01]`) and today.

  ## Examples

      iex> NeoFaker.Date.between()
      ~D[2025-03-25]

      iex> NeoFaker.Date.between(~D[2020-01-01], ~D[2025-01-01])
      ~D[2022-08-17]

  """
  @spec between(Date.t(), Date.t()) :: Date.t()
  def between(start \\ @epoch_date, finish \\ Generator.local_date_now()) do
    Validator.validate_date_order!(start, finish)

    Generator.between(start, finish)
  end

  @doc """
  Generates a random birthday within the specified age range.

  Calculates the valid date window from the current date and `min_age`/`max_age` (defaulting
  to `18` and `65` respectively), then returns a random date within that window.

  ## Examples

      iex> NeoFaker.Date.birthday()
      ~D[1997-01-02]

      iex> NeoFaker.Date.birthday(18, 65)
      ~D[1998-03-04]

  """
  @doc since: "0.10.0"
  @spec birthday(non_neg_integer(), non_neg_integer()) :: Date.t()
  def birthday(min_age \\ @min_age, max_age \\ @max_age) do
    Validator.validate_age_range!(min_age, max_age)

    today = Generator.local_date_now()
    start_date = today |> Date.shift(year: -(max_age + 1)) |> Date.add(1)
    finish_date = Date.shift(today, year: -min_age)

    Generator.between(start_date, finish_date)
  end

  @doc """
  Generates a random date in the past.

  Returns a random date between `days` ago (defaults to `365`) and today. Equivalent to
  `add(-days..0)`.

  ## Examples

      iex> NeoFaker.Date.past(30)
      ~D[2025-02-25]

  """
  @spec past(pos_integer()) :: Date.t()
  def past(days \\ 365)

  def past(days) when is_integer(days) and days > 0, do: add(-days..0)

  def past(days) do
    raise ArgumentError, "days must be a positive integer, got: #{inspect(days)}"
  end

  @doc """
  Generates a random date in the future.

  Returns a random date between today and `days` from now (defaults to `365`). Equivalent to
  `add(0..days)`.

  ## Examples

      iex> NeoFaker.Date.future(30)
      ~D[2025-04-24]

  """
  @spec future(pos_integer()) :: Date.t()
  def future(days \\ 365)

  def future(days) when is_integer(days) and days > 0, do: add(0..days)

  def future(days) do
    raise ArgumentError, "days must be a positive integer, got: #{inspect(days)}"
  end

  @doc """
  Returns today's local date.

  A convenience wrapper that always returns the current date without any randomisation.

  ## Examples

      iex> NeoFaker.Date.today()
      ~D[2025-03-25]

  """
  @spec today() :: Date.t()
  def today, do: Generator.local_date_now()
end
