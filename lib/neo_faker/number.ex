defmodule NeoFaker.Number do
  @moduledoc """
  Provides functions for generating random numbers.

  This module offers utilities for producing random numbers, including generating values within
  a specified range.
  """
  @moduledoc since: "0.8.0"

  @doc """
  Generates a random number between `min` and `max`.

  If both arguments are integers, the result is a random integer within the range.
  If they are floats, a random float is returned instead.

  ## Examples

      iex> NeoFaker.Number.between()
      27

      iex> NeoFaker.Number.between(1, 100)
      28

      iex> NeoFaker.Number.between(1.0, 100.0)
      29.481745280074264

  """
  @spec between(number(), number()) :: number()
  def between(min \\ 0, max \\ 100)
  def between(min, max) when is_integer(min) and is_integer(max), do: Enum.random(min..max)

  def between(min, max) when is_float(min) and is_float(max) do
    :rand.uniform() * (max - min) + min
  end

  @doc """
  Generates a random floating-point number within the given range.

  The integer part is selected from `left_digit`, and the fractional part from `right_digit`.
  Both arguments are ranges, and the function returns a float by combining a random value from each.

  ## Examples

      iex> NeoFaker.Number.decimal()
      30.94372

      iex> NeoFaker.Number.decimal(1..9, 10..90)
      1.44

  """
  @spec decimal(Range.t(), Range.t()) :: float()
  def decimal(left_digit \\ 10..100, right_digit \\ 10_000..100_000) do
    decimal_number = "#{Enum.random(left_digit)}.#{Enum.random(right_digit)}"

    String.to_float(decimal_number)
  end

  @doc """
  Generates a random digit between 0 and 9.

  ## Examples

      iex> NeoFaker.Number.digit()
      5

  """
  @spec digit() :: integer()
  def digit, do: Enum.random(0..9)
end
