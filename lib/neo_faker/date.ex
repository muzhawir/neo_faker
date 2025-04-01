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

      iex> NeoFaker.Date.add(format: :iso8601)
      "2025-03-25"

  """
  @spec add(Range.t(), Keyword.t()) :: Date.t() | String.t()
  def add(range \\ -365..365, opts \\ []) do
    type = Keyword.get(opts, :format, :date)

    random_date(range, type)
  end
end
