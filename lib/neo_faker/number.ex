defmodule NeoFaker.Number do
  @moduledoc """
  Functions for generating random numbers.

  Integer functions draw uniformly from an inclusive range. Float functions draw
  uniformly between their bounds and can be rounded to a fixed number of decimal places.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Helpers.Validator
  alias NeoFaker.Number.Generator
  alias NeoFaker.Number.Validator, as: NumberValidator

  @doc """
  Generates a random number between `min` and `max`, inclusive.

  Returns an integer when both bounds are integers, and a float when either bound is a
  float. `min` defaults to `0` and `max` defaults to `100`.

  Raises `ArgumentError` if either bound is not a number, or if `min` is greater than
  `max`.

  ## Examples

      iex> NeoFaker.Number.between()
      27

      iex> NeoFaker.Number.between(1, 6)
      4

      iex> NeoFaker.Number.between(20, 100.0)
      29.481745280074264

      iex> NeoFaker.Number.between(100, 1)
      ** (ArgumentError) min must be less than or equal to max, got: min=100, max=1

  """
  @spec between(number(), number()) :: number()
  def between(min \\ 0, max \\ 100)

  def between(min, max) when is_number(min) and is_number(max) and min > max do
    raise ArgumentError,
          "min must be less than or equal to max, got: min=#{inspect(min)}, max=#{inspect(max)}"
  end

  def between(min, max) when is_integer(min) and is_integer(max), do: Enum.random(min..max//1)

  def between(min, max) when is_number(min) and is_number(max) do
    Generator.float_between(Generator.to_float(min), Generator.to_float(max))
  end

  def between(min, max) do
    raise ArgumentError,
          "min and max must be numbers, got: min=#{inspect(min)}, max=#{inspect(max)}"
  end

  @doc """
  Generates a random float by joining two random integers with a decimal point.

  The integer part is drawn from `left_digit`, which defaults to `10..100`. The digits
  after the decimal point are drawn from `right_digit`, which defaults to
  `10_000..100_000`, and are written as-is: a draw of `42` gives `.42`, not `.00042`.

  Raises `ArgumentError` if either argument is not a non-empty range, or if
  `right_digit` contains a negative number.

  ## Examples

      iex> NeoFaker.Number.float()
      30.94372

      iex> NeoFaker.Number.float(1..9, 10..90)
      1.44

  """
  @spec float(Range.t(), Range.t()) :: float()
  def float(left_digit \\ 10..100, right_digit \\ 10_000..100_000) do
    left = left_digit |> Validator.validate_range!("left_digit") |> Enum.random()
    right = right_digit |> NumberValidator.validate_fraction_range!() |> Enum.random()

    String.to_float("#{left}.#{right}")
  end

  @doc """
  Generates a random digit from `0` to `9`.

  ## Examples

      iex> NeoFaker.Number.digit()
      5

  """
  @spec digit() :: 0..9
  def digit, do: Enum.random(0..9)

  @doc """
  Generates a random integer between `1` and `max`, inclusive.

  `max` defaults to `100`. Raises `ArgumentError` if `max` is not a positive integer.

  ## Examples

      iex> NeoFaker.Number.positive()
      42

      iex> NeoFaker.Number.positive(50)
      27

      iex> NeoFaker.Number.positive(0)
      ** (ArgumentError) max must be a positive integer, got: 0

  """
  @spec positive(pos_integer()) :: pos_integer()
  def positive(max \\ 100)
  def positive(max) when is_integer(max) and max >= 1, do: Enum.random(1..max)

  def positive(max) do
    raise ArgumentError, "max must be a positive integer, got: #{inspect(max)}"
  end

  @doc """
  Generates a random integer between `min` and `-1`, inclusive.

  `min` defaults to `-100`. Raises `ArgumentError` if `min` is not a negative integer.

  ## Examples

      iex> NeoFaker.Number.negative()
      -42

      iex> NeoFaker.Number.negative(-50)
      -27

  """
  @spec negative(neg_integer()) :: neg_integer()
  def negative(min \\ -100)
  def negative(min) when is_integer(min) and min <= -1, do: Enum.random(min..-1//1)

  def negative(min) do
    raise ArgumentError, "min must be a negative integer, got: #{inspect(min)}"
  end

  @doc """
  Generates a random float between `min` and `max`, rounded to `precision` decimal places.

  `min` defaults to `0.0`, `max` to `100.0`, and `precision` to `2`. Because of the
  rounding, the result can equal either bound.

  Raises `ArgumentError` if `min` or `max` is not a number, if `min` is greater than
  `max`, or if `precision` is not an integer from `0` to `15`.

  ## Examples

      iex> NeoFaker.Number.decimal()
      42.73

      iex> NeoFaker.Number.decimal(0.0, 1.0, 4)
      0.7384

      iex> NeoFaker.Number.decimal(100.0, 0.0)
      ** (ArgumentError) min must be less than or equal to max, got: min=100.0, max=0.0

  """
  @spec decimal(number(), number(), 0..15) :: float()
  def decimal(min \\ 0.0, max \\ 100.0, precision \\ 2) do
    NumberValidator.validate_precision!(precision)

    # Integer bounds are widened to floats so that `between/2` draws a float.
    {min, max} = {widen(min), widen(max)}

    min |> between(max) |> Float.round(precision)
  end

  defp widen(n) when is_integer(n), do: Generator.to_float(n)
  defp widen(n), do: n
end
