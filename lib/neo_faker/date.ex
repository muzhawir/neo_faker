defmodule NeoFaker.Date do
  @moduledoc """
  Functions for generating random dates.

  This module provides utilities to generate random dates, including dates within a specific
  range, birthdays, and more.
  """
  @moduledoc since: "0.9.0"

  import NeoFaker.Date.Utils

  @doc """
  Generates a random date.

  Returns a date within the default range of 365 days before and 365 days after today.

  ## Options

  - `:format` - Specifies the format of the date.

  The values for `:format` can be:

  - `:date` - Returns the date in `Date` format (default).
  - `:iso8601` - Returns the date in ISO 8601 format.

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
    format = Keyword.get(opts, :format, :date)

    random_add_date(range, format)
  end

  @doc """
  Generates a random date between two dates.

  Returns a date between the specified start and finish dates.

  ## Options

  - `:format` - Specifies the format of the date.

  The values for `:format` can be:

  - `:date` - Returns the date in `Date` format (default).
  - `:iso8601` - Returns the date in ISO 8601 format.

  ## Examples

      iex> NeoFaker.Date.between()
      ~D[2025-03-25]

      iex> NeoFaker.Date.between(~D[2020-01-01], ~D[2025-01-01])
      ~D[2022-08-17]

      iex> NeoFaker.Date.between(~D[2025-03-25], ~D[2025-03-25], format: :iso8601)
      "2025-03-25"

  """
  @spec between(Date.t(), Date.t(), Keyword.t()) :: Date.t() | String.t()
  def between(start \\ ~D[1970-01-01], finish \\ Date.utc_today(), opts \\ []) do
    format = Keyword.get(opts, :format, :date)

    random_between_date(start, finish, format)
  end
end
