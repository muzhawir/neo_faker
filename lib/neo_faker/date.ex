defmodule NeoFaker.Date do
  @moduledoc """
  Functions for generating random dates.

  Provides utilities to generate random dates, including dates relative to today,
  dates within a custom range, birthdays, past and future dates. All functions
  support both `Date` struct and ISO 8601 string output formats.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Date.Generator
  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options

  @epoch_date ~D[1970-01-01]
  @min_age Constants.default_age_min()
  @max_age Constants.default_age_max()

  @doc """
  Generates a random date within a specified range relative to today.

  By default, returns a date between 365 days before and 365 days after the current date.
  The range parameter specifies the number of days to add or subtract from today.

  ## Parameters

  - `range` - The range of days relative to today. Defaults to `-365..365`.
  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Options

  The values for `:format` can be:

  - `:struct` - Returns a `Date` struct (default).
  - `:iso8601` - Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Date.add()
      ~D[2025-03-25]

      iex> NeoFaker.Date.add(0..31)
      ~D[2025-03-30]

      iex> NeoFaker.Date.add(0..31, format: :iso8601)
      "2025-03-25"

  """
  @spec add(Range.t(), Keyword.t()) :: Date.t() | String.t()
  def add(range \\ Constants.default_date_range(), opts \\ []) do
    validate_range!(range)
    format = get_and_validate_format!(opts)

    range |> Generator.add(:struct) |> Formatter.format_date(format)
  end

  @doc """
  Generates a random date between two given dates.

  Both `start` and `finish` are inclusive. Defaults to a date between the Unix
  epoch (`~D[1970-01-01]`) and today.

  ## Parameters

  - `start` - The start date (inclusive). Defaults to `~D[1970-01-01]`.
  - `finish` - The end date (inclusive). Defaults to today's date.
  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Options

  The values for `:format` can be:

  - `:struct` - Returns a `Date` struct (default).
  - `:iso8601` - Returns an ISO 8601 formatted string.

  ## Examples

      iex> NeoFaker.Date.between()
      ~D[2025-03-25]

      iex> NeoFaker.Date.between(~D[2020-01-01], ~D[2025-01-01])
      ~D[2022-08-17]

      iex> NeoFaker.Date.between(~D[2025-03-25], ~D[2025-03-25], format: :iso8601)
      "2025-03-25"

  """
  @spec between(Date.t(), Date.t(), Keyword.t()) :: Date.t() | String.t()
  def between(start \\ @epoch_date, finish \\ Generator.local_date_now(), opts \\ []) do
    validate_date_order!(start, finish)
    format = get_and_validate_format!(opts)

    start |> Generator.between(finish, :struct) |> Formatter.format_date(format)
  end

  @doc """
  Generates a random birthday within the specified age range.

  Calculates the valid date window from the current date and `min_age`/`max_age`,
  then returns a random date within that window.

  ## Parameters

  - `min_age` - The minimum age in years. Defaults to `18`.
  - `max_age` - The maximum age in years. Defaults to `65`.
  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Options

  The values for `:format` can be:

  - `:struct` - Returns a `Date` struct (default).
  - `:iso8601` - Returns an ISO 8601 formatted string.

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
  def birthday(min_age \\ @min_age, max_age \\ @max_age, opts \\ []) do
    validate_age_range!(min_age, max_age)
    format = get_and_validate_format!(opts)

    today = Generator.local_date_now()
    start_date = Date.shift(today, year: -max_age)
    finish_date = Date.shift(today, year: -min_age)

    start_date |> Generator.between(finish_date, :struct) |> Formatter.format_date(format)
  end

  @doc """
  Generates a random date in the past.

  Returns a random date between `days` ago and today. Equivalent to
  `add(-days..0, opts)`.

  ## Parameters

  - `days` - The number of days in the past to look back. Defaults to `365`.
  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.past(30)
      ~D[2025-02-25]

      iex> NeoFaker.Date.past(365, format: :iso8601)
      "2024-03-25"

  """
  @spec past(pos_integer(), Keyword.t()) :: Date.t() | String.t()
  def past(days \\ 365, opts \\ []) when is_integer(days) and days > 0 do
    add(-days..0, opts)
  end

  @doc """
  Generates a random date in the future.

  Returns a random date between today and `days` from now. Equivalent to
  `add(0..days, opts)`.

  ## Parameters

  - `days` - The number of days ahead to look. Defaults to `365`.
  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.future(30)
      ~D[2025-04-24]

      iex> NeoFaker.Date.future(365, format: :iso8601)
      "2026-03-25"

  """
  @spec future(pos_integer(), Keyword.t()) :: Date.t() | String.t()
  def future(days \\ 365, opts \\ []) when is_integer(days) and days > 0 do
    add(0..days, opts)
  end

  @doc """
  Returns today's local date.

  A convenience wrapper that always returns the current date without any
  randomisation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:struct`.

  ## Examples

      iex> NeoFaker.Date.today()
      ~D[2025-03-25]

      iex> NeoFaker.Date.today(format: :iso8601)
      "2025-03-25"

  """
  @spec today(Keyword.t()) :: Date.t() | String.t()
  def today(opts \\ []) do
    format = get_and_validate_format!(opts)
    date = Generator.local_date_now()
    Formatter.format_date(date, format)
  end

  # Private functions

  @spec get_and_validate_format!(Keyword.t()) :: atom()
  defp get_and_validate_format!(opts) do
    format = Options.get(opts, :format, :struct)
    valid_formats = Constants.valid_datetime_formats()

    case Options.validate_enum(:format, format, valid_formats) do
      :ok ->
        format

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_range!(Range.t()) :: :ok
  defp validate_range!(range) when is_struct(range, Range) do
    if range.first <= range.last do
      :ok
    else
      raise ArgumentError, "Invalid range: first must be less than or equal to last"
    end
  end

  defp validate_range!(invalid) do
    raise ArgumentError, "Expected a Range, got: #{inspect(invalid)}"
  end

  @spec validate_date_order!(Date.t(), Date.t()) :: :ok
  defp validate_date_order!(start, finish) do
    case Date.compare(start, finish) do
      :gt ->
        raise ArgumentError, "start date must be before or equal to finish date"

      _ ->
        :ok
    end
  end

  @spec validate_age_range!(non_neg_integer(), non_neg_integer()) :: :ok
  defp validate_age_range!(min_age, max_age) when is_integer(min_age) and is_integer(max_age) do
    cond do
      min_age < 0 ->
        raise ArgumentError, "min_age must be non-negative, got: #{min_age}"

      max_age < 0 ->
        raise ArgumentError, "max_age must be non-negative, got: #{max_age}"

      min_age > max_age ->
        raise ArgumentError, "min_age must be less than or equal to max_age"

      true ->
        :ok
    end
  end

  defp validate_age_range!(min_age, _max_age) when not is_integer(min_age) do
    raise ArgumentError, "min_age must be an integer, got: #{inspect(min_age)}"
  end

  defp validate_age_range!(_min_age, max_age) when not is_integer(max_age) do
    raise ArgumentError, "max_age must be an integer, got: #{inspect(max_age)}"
  end
end
