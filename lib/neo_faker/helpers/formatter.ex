defmodule NeoFaker.Helpers.Formatter do
  @moduledoc """
  Provides utilities for standardizing format conversions across NeoFaker modules.

  This module centralizes common patterns for converting data between different formats,
  such as structs to strings, tuples to W3C format, etc.
  """
  @moduledoc since: "0.14.0"

  @doc """
  Formats a Date struct according to the specified format.

  ## Options

  - `:struct` - Returns the Date struct as-is
  - `:iso8601` - Returns an ISO 8601 formatted string

  ## Examples

      iex> NeoFaker.Helpers.Formatter.format_date(~D[2025-03-25], :struct)
      ~D[2025-03-25]

      iex> NeoFaker.Helpers.Formatter.format_date(~D[2025-03-25], :iso8601)
      "2025-03-25"

  """
  @spec format_date(Date.t(), :struct | :iso8601) :: Date.t() | String.t()
  def format_date(date, :struct), do: date
  def format_date(date, :iso8601), do: Date.to_iso8601(date)

  @doc """
  Formats a Time struct according to the specified format.

  ## Options

  - `:struct` - Returns the Time struct as-is
  - `:iso8601` - Returns an ISO 8601 formatted string

  ## Examples

      iex> NeoFaker.Helpers.Formatter.format_time(~T[15:22:10], :struct)
      ~T[15:22:10]

      iex> NeoFaker.Helpers.Formatter.format_time(~T[15:22:10], :iso8601)
      "15:22:10"

  """
  @spec format_time(Time.t(), :struct | :iso8601) :: Time.t() | String.t()
  def format_time(time, :struct), do: time
  def format_time(time, :iso8601), do: Time.to_iso8601(time)

  @doc """
  Formats a DateTime struct according to the specified format.

  ## Options

  - `:struct` - Returns the DateTime struct as-is
  - `:iso8601` - Returns an ISO 8601 formatted string

  ## Examples

      iex> dt = ~U[2025-03-25 15:22:10Z]
      iex> NeoFaker.Helpers.Formatter.format_datetime(dt, :struct)
      ~U[2025-03-25 15:22:10Z]

      iex> dt = ~U[2025-03-25 15:22:10Z]
      iex> NeoFaker.Helpers.Formatter.format_datetime(dt, :iso8601)
      "2025-03-25T15:22:10Z"

  """
  @spec format_datetime(DateTime.t(), :struct | :iso8601) :: DateTime.t() | String.t()
  def format_datetime(datetime, :struct), do: datetime
  def format_datetime(datetime, :iso8601), do: DateTime.to_iso8601(datetime)

  @doc """
  Formats a color tuple to W3C format string.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.format_color_w3c({255, 128, 64}, "rgb")
      "rgb(255, 128, 64)"

      iex> NeoFaker.Helpers.Formatter.format_color_w3c({0, 25, 50, 100}, "cmyk", "%")
      "cmyk(0%, 25%, 50%, 100%)"

  """
  @spec format_color_w3c(tuple(), String.t(), String.t()) :: String.t()
  def format_color_w3c(color_tuple, color_type, suffix \\ "") when is_tuple(color_tuple) do
    values =
      color_tuple
      |> Tuple.to_list()
      |> Enum.map_join(", ", &"#{&1}#{suffix}")

    "#{color_type}(#{values})"
  end

  @doc """
  Formats a number as a string or returns as integer based on type.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.format_number(42, :string)
      "42"

      iex> NeoFaker.Helpers.Formatter.format_number(42, :integer)
      42

  """
  @spec format_number(number(), :string | :integer) :: String.t() | integer()
  def format_number(number, :string) when is_integer(number), do: Integer.to_string(number)
  def format_number(number, :string) when is_float(number), do: Float.to_string(number)
  def format_number(number, :integer) when is_integer(number), do: number
  def format_number(number, :integer) when is_float(number), do: trunc(number)

  @doc """
  Formats a boolean as an integer or returns as boolean.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.format_boolean(true, :integer)
      1

      iex> NeoFaker.Helpers.Formatter.format_boolean(false, :integer)
      0

      iex> NeoFaker.Helpers.Formatter.format_boolean(true, :boolean)
      true

  """
  @spec format_boolean(boolean(), :boolean | :integer) :: boolean() | 0 | 1
  def format_boolean(value, :boolean), do: value
  def format_boolean(true, :integer), do: 1
  def format_boolean(false, :integer), do: 0

  @doc """
  Applies case transformation to a string.

  ## Options

  - `:upper` - Converts to uppercase
  - `:lower` - Converts to lowercase
  - `:none` - Returns unchanged

  ## Examples

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :upper)
      "HELLO"

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :lower)
      "hello"

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :none)
      "Hello"

  """
  @spec apply_case(String.t(), :upper | :lower | :none) :: String.t()
  def apply_case(string, :upper), do: String.upcase(string)
  def apply_case(string, :lower), do: String.downcase(string)
  def apply_case(string, :none), do: string

  @doc """
  Adds or removes a prefix from a string based on a boolean condition.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.with_prefix("example", ".", true)
      ".example"

      iex> NeoFaker.Helpers.Formatter.with_prefix("example", ".", false)
      "example"

  """
  @spec with_prefix(String.t(), String.t(), boolean()) :: String.t()
  def with_prefix(string, prefix, true), do: prefix <> string
  def with_prefix(string, _prefix, false), do: string

  @doc """
  Adds or removes a suffix from a string based on a boolean condition.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.with_suffix("example", ".com", true)
      "example.com"

      iex> NeoFaker.Helpers.Formatter.with_suffix("example", ".com", false)
      "example"

  """
  @spec with_suffix(String.t(), String.t(), boolean()) :: String.t()
  def with_suffix(string, suffix, true), do: string <> suffix
  def with_suffix(string, _suffix, false), do: string
end
