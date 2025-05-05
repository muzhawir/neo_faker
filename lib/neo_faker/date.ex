defmodule NeoFaker.Date do
  @moduledoc """
  Functions for generating random dates.

  This module provides utilities to generate random dates, including dates within a specific
  range, birthdays, and more.
  """
  @moduledoc since: "0.9.0"

  import NeoFaker.Date.Utils

  @doc """
  Generates a random date within a specified range relative to today.

  By default, returns a date between 365 days before and 365 days after the current date.
  The output format can be either a `Date` struct (`~D` sigil) or an ISO 8601 string, depending
  on the `:format` option.

  ## Options

  - `:format` - Specifies the output format of the date.

  The values for `:format` can be:

  - `:struct` - Returns a `Date` struct.
  - `:iso8601` — Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Date.add()
      ~D[2025-03-25]

      iex> NeoFaker.Date.add(0..31)
      ~D[2025-03-30]

      iex> NeoFaker.Date.add(0..31, format: :iso8601)
      "2025-03-25"

  """
  @spec add(Range.t(), Keyword.t()) :: Date.t() | String.t()
  def add(range \\ -365..365, opts \\ []) do
    random_add_date(range, Keyword.get(opts, :format, :struct))
  end

  @doc """
  Generates a random date between two given dates.

  By default, returns a date between January 1, 1970 and today. The output format can be specified
  as either a `Date` struct (`:struct`, default) or an ISO 8601 string (`:iso8601`).

  ## Options

  - `:format` - Specifies the output format of the date.

  The values for `:format` can be:

  - `:struct` - Returns a `Date` struct.
  - `:iso8601` — Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Date.between()
      ~D[2025-03-25]

      iex> NeoFaker.Date.between(~D[2020-01-01], ~D[2025-01-01])
      ~D[2022-08-17]

      iex> NeoFaker.Date.between(~D[2025-03-25], ~D[2025-03-25], format: :iso8601)
      "2025-03-25"

  """
  @spec between(Date.t(), Date.t(), Keyword.t()) :: Date.t() | String.t()
  def between(start \\ ~D[1970-01-01], finish \\ local_date_now(), opts \\ []) do
    random_between_date(start, finish, Keyword.get(opts, :format, :struct))
  end

  @doc """
  Generates a random birthday.

  Returns a birthday within the specified age range.

  ## Options

  - `:format` - Specifies the format of the date.

  The values for `:format` can be:

  - `:struct` - Returns a `Date` struct.
  - `:iso8601` — Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Date.birthday()
      ~D[1997-01-02]

      iex> NeoFaker.Date.birthday(18, 65)
      ~D[1998-03-04]

      iex> NeoFaker.Date.birthday(18, 65, format: :iso8601)
      "1999-05-06"

  """
  @doc since: "0.10.0"
  @spec birthday(non_neg_integer(), non_neg_integer(), Keyword.t()) :: Date.t() | String.t()
  def birthday(min_age \\ 18, max_age \\ 65, opts \\ []) do
    today = NaiveDateTime.local_now()

    random_between_date(
      Date.shift(today, year: -max_age),
      Date.shift(today, year: -min_age),
      Keyword.get(opts, :format, :struct)
    )
  end
end
