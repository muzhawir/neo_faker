defmodule NeoFaker.Helpers.Formatter do
  @moduledoc false
  @moduledoc since: "0.14.0"

  # Shared output-shaping helpers for the small set of format/case/prefix-suffix
  # options that recur across multiple domains, so each domain module doesn't
  # reimplement the same "if :iso8601 then to_string else pass through" branch.

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
  Converts `number` to a string, or coerces it to an integer.

  The `:integer` branch truncates a float toward zero (`trunc/1`), it does not round to the
  nearest integer, so `format_number(2.9, :integer)` returns `2`, not `3`.

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
end
