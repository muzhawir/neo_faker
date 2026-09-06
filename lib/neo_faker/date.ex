defmodule NeoFaker.Date do
  @moduledoc """
  Functions for generating random dates.

  Provides utilities to generate random dates, including dates relative to today,
  dates within a custom range, birthdays, past and future dates. All functions
  support both `Date` struct and ISO 8601 string output formats.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Date.Generator
  alias NeoFaker.Date.Validator
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options

  @epoch_date ~D[1970-01-01]
  @date_range -365..365
  @min_age 18
  @max_age 65

  @format_schema NimbleOptions.new!(format: [type: {:in, [:struct, :iso8601]}, default: :struct])

  @doc """
  Generates a random date within a specified range relative to today.

  By default, returns a date between 365 days before and 365 days after the current date.
  `range` specifies the number of days to add or subtract from today.

  ## Options

    * `:format` (`:struct` or `:iso8601`) - the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.add()
      ~D[2025-03-25]

      iex> NeoFaker.Date.add(0..31)
      ~D[2025-03-30]

      iex> NeoFaker.Date.add(0..31, format: :iso8601)
      "2025-03-25"

  """
  @spec add(Range.t(), keyword()) :: Date.t() | String.t()
  def add(range \\ @date_range, opts \\ []) do
    Validator.validate_range!(range)
    opts = Options.validate!(opts, @format_schema)

    range |> Generator.add(:struct) |> Formatter.format_date(Keyword.fetch!(opts, :format))
  end

  @doc """
  Generates a random date between two given dates.

  Both `start` and `finish` are inclusive. Defaults to a date between the Unix
  epoch (`~D[1970-01-01]`) and today.

  ## Options

    * `:format` (`:struct` or `:iso8601`) - the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.between()
      ~D[2025-03-25]

      iex> NeoFaker.Date.between(~D[2020-01-01], ~D[2025-01-01])
      ~D[2022-08-17]

      iex> NeoFaker.Date.between(~D[2025-03-25], ~D[2025-03-25], format: :iso8601)
      "2025-03-25"

  """
  @spec between(Date.t(), Date.t(), keyword()) :: Date.t() | String.t()
  def between(start \\ @epoch_date, finish \\ Generator.local_date_now(), opts \\ []) do
    Validator.validate_date_order!(start, finish)
    opts = Options.validate!(opts, @format_schema)

    start
    |> Generator.between(finish, :struct)
    |> Formatter.format_date(Keyword.fetch!(opts, :format))
  end

  @doc """
  Generates a random birthday within the specified age range.

  Calculates the valid date window from the current date and `min_age`/`max_age` (defaulting
  to `18` and `65` respectively), then returns a random date within that window.

  ## Options

    * `:format` (`:struct` or `:iso8601`) - the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.birthday()
      ~D[1997-01-02]

      iex> NeoFaker.Date.birthday(18, 65)
      ~D[1998-03-04]

      iex> NeoFaker.Date.birthday(18, 65, format: :iso8601)
      "1999-05-06"

  """
  @doc since: "0.10.0"
  @spec birthday(non_neg_integer(), non_neg_integer(), keyword()) :: Date.t() | String.t()
  def birthday(min_age \\ @min_age, max_age \\ @max_age, opts \\ []) do
    Validator.validate_age_range!(min_age, max_age)
    opts = Options.validate!(opts, @format_schema)

    today = Generator.local_date_now()

    start_date =
      today
      |> Date.shift(year: -(max_age + 1))
      |> Date.add(1)

    finish_date = Date.shift(today, year: -min_age)

    start_date
    |> Generator.between(finish_date, :struct)
    |> Formatter.format_date(Keyword.fetch!(opts, :format))
  end

  @doc """
  Generates a random date in the past.

  Returns a random date between `days` ago (defaults to `365`) and today. Equivalent to
  `add(-days..0, opts)`.

  ## Options

    * `:format` (`:struct` or `:iso8601`) - the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.past(30)
      ~D[2025-02-25]

      iex> NeoFaker.Date.past(365, format: :iso8601)
      "2024-03-25"

  """
  @spec past(pos_integer(), keyword()) :: Date.t() | String.t()
  def past(days \\ 365, opts \\ []) when is_integer(days) and days > 0 do
    add(-days..0, opts)
  end

  @doc """
  Generates a random date in the future.

  Returns a random date between today and `days` from now (defaults to `365`). Equivalent to
  `add(0..days, opts)`.

  ## Options

    * `:format` (`:struct` or `:iso8601`) - the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.future(30)
      ~D[2025-04-24]

      iex> NeoFaker.Date.future(365, format: :iso8601)
      "2026-03-25"

  """
  @spec future(pos_integer(), keyword()) :: Date.t() | String.t()
  def future(days \\ 365, opts \\ []) when is_integer(days) and days > 0 do
    add(0..days, opts)
  end

  @doc """
  Returns today's local date.

  A convenience wrapper that always returns the current date without any randomisation.

  ## Options

    * `:format` (`:struct` or `:iso8601`) - the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.today()
      ~D[2025-03-25]

      iex> NeoFaker.Date.today(format: :iso8601)
      "2025-03-25"

  """
  @spec today(keyword()) :: Date.t() | String.t()
  def today(opts \\ []) do
    opts = Options.validate!(opts, @format_schema)
    date = Generator.local_date_now()
    Formatter.format_date(date, Keyword.fetch!(opts, :format))
  end
end
