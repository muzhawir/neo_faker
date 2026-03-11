defmodule NeoFaker.Number do
  @moduledoc """
  Functions for generating random numbers.

  Provides utilities to generate random integers, floats, digits, and decimals, including
  values within a specified range and numbers with controlled precision.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Number.Generator
  alias NeoFaker.Number.Validator

  @min 0
  @max 100
  @left_digit_range 10..100
  @right_digit_range 10_000..100_000
  @digit_range 0..9

  @doc """
  Generates a random number between `min` and `max`.

  Returns an integer when both arguments are integers, or a float when either argument is a
  float. Defaults to the range `0`–`100`.

  ## Parameters

  - `min` - Minimum value (inclusive). Defaults to `0`.
  - `max` - Maximum value (inclusive). Defaults to `100`.

  ## Examples

      iex> NeoFaker.Number.between()
      27

      iex> NeoFaker.Number.between(1, 100)
      28

      iex> NeoFaker.Number.between(20, 100.0)
      29.481745280074264

      iex> NeoFaker.Number.between(50, 50)
      50

      iex> NeoFaker.Number.between(100, 1)
      ** (ArgumentError) min must be less than or equal to max, got: min=100, max=1

  """
  @spec between(number(), number()) :: number()
  def between(min \\ @min, max \\ @max)

  def between(min, max) when is_number(min) and is_number(max) and min > max do
    raise ArgumentError, "min must be less than or equal to max, got: min=#{min}, max=#{max}"
  end

  def between(min, max) when is_integer(min) and is_integer(max) do
    Enum.random(min..max)
  end

  def between(min, max) when is_float(min) and is_float(max) do
    Generator.float_between(min, max)
  end

  def between(min, max) when is_number(min) and is_number(max) do
    between(Generator.to_float(min), Generator.to_float(max))
  end

  @doc """
  Generates a random floating-point number within the given range.

  Combines a randomly selected integer part from `left_digit` and a fractional part from
  `right_digit` into a float. Defaults to `10..100` for the integer part and
  `10_000..100_000` for the fractional part.

  ## Parameters

  - `left_digit` - Range for the integer part. Defaults to `10..100`.
  - `right_digit` - Range for the fractional part. Defaults to `10_000..100_000`.

  ## Examples

      iex> NeoFaker.Number.float()
      30.94372

      iex> NeoFaker.Number.float(1..9, 10..90)
      1.44

      iex> NeoFaker.Number.float(10..5, 10..100)
      ** (ArgumentError) left_digit range must have first <= last, got: 10..5

  """
  @spec float(Range.t(), Range.t()) :: float()
  def float(left_digit \\ @left_digit_range, right_digit \\ @right_digit_range) do
    Validator.validate_range!(left_digit, "left_digit")
    Validator.validate_range!(right_digit, "right_digit")

    left = Enum.random(left_digit)
    right = Enum.random(right_digit)

    String.to_float("#{left}.#{right}")
  end

  @doc """
  Generates a random single digit between `0` and `9`.

  ## Examples

      iex> NeoFaker.Number.digit()
      5

  """
  @spec digit() :: integer()
  def digit, do: Enum.random(@digit_range)

  @doc """
  Generates a random positive integer between `1` and `max`.

  ## Parameters

  - `max` - Maximum value (inclusive). Defaults to `100`.

  ## Examples

      iex> NeoFaker.Number.positive(50)
      27

      iex> NeoFaker.Number.positive()
      42

      iex> NeoFaker.Number.positive(0)
      ** (ArgumentError) max must be at least 1, got: 0

  """
  @spec positive(pos_integer()) :: pos_integer()
  def positive(max \\ @max)

  def positive(max) when is_integer(max) and max >= 1, do: between(1, max)

  def positive(max) when is_integer(max) do
    raise ArgumentError, "max must be at least 1, got: #{max}"
  end

  @doc """
  Generates a random negative integer between `min` and `-1`.

  ## Parameters

  - `min` - Minimum value (inclusive). Defaults to `-100`.

  ## Examples

      iex> NeoFaker.Number.negative(-50)
      -27

      iex> NeoFaker.Number.negative()
      -42

  """
  @spec negative(neg_integer()) :: neg_integer()
  def negative(min \\ -@max)

  def negative(min) when is_integer(min) and min <= -1, do: between(min, -1)

  def negative(min) when is_integer(min) do
    raise ArgumentError, "min must be at most -1, got: #{min}"
  end

  @doc """
  Generates a random float rounded to the specified number of decimal places.

  ## Parameters

  - `min` - Minimum value (inclusive). Defaults to `0.0`.
  - `max` - Maximum value (inclusive). Defaults to `100.0`.
  - `precision` - Number of decimal places. Defaults to `2`.

  ## Examples

      iex> NeoFaker.Number.decimal(0.0, 10.0, 2)
      5.47

      iex> NeoFaker.Number.decimal(0.0, 1.0, 4)
      0.7384

      iex> NeoFaker.Number.decimal()
      42.73

      iex> NeoFaker.Number.decimal(100.0, 0.0)
      ** (ArgumentError) min must be less than or equal to max, got: min=100.0, max=0.0

  """
  @spec decimal(number(), number(), non_neg_integer()) :: float()
  def decimal(min \\ 0.0, max \\ 100.0, precision \\ 2)

  def decimal(min, max, precision)
      when is_number(min) and is_number(max) and is_integer(precision) and precision >= 0 do
    min
    |> Generator.to_float()
    |> between(Generator.to_float(max))
    |> Float.round(precision)
  end

  def decimal(min, max, precision)
      when is_number(min) and is_number(max) and is_integer(precision) do
    raise ArgumentError,
          "precision must be greater than or equal to 0, got: #{precision}"
  end
end
