defmodule NeoFaker.Number do
  @moduledoc """
  Functions for generating random numbers.

  This module provides utilities to generate random numbers, including values within a specified
  range.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Number.Utils

  @doc """
  Generates a random number between `min` and `max`.

  If both arguments are integers, the result is a random integer within the range. If they are
  floats, a random float within the range is returned.

  ## Examples

      iex> NeoFaker.Number.between()
      27

      iex> NeoFaker.Number.between(1, 100)
      28

      iex> NeoFaker.Number.between(1.0, 100.0)
      29.481745280074264

  """
  @spec between(number(), number()) :: number()
  defdelegate between(min \\ 0, max \\ 100), to: Utils, as: :between

  @doc """
  Generates a random floating-point number within the given range.

  The integer part is selected from `left_digit`, and the fractional part from `right_digit`.
  Both arguments are ranges, and the function returns a float by combining a random value from
  each.

  ## Examples

      iex> NeoFaker.Number.float()
      30.94372

      iex> NeoFaker.Number.float(1..9, 10..90)
      1.44

  """
  @spec float(Range.t(), Range.t()) :: float()
  def float(left_digit \\ 10..100, right_digit \\ 10_000..100_000) do
    decimal_number = "#{Enum.random(left_digit)}.#{Enum.random(right_digit)}"

    String.to_float(decimal_number)
  end

  @doc """
  Generates a random digit between `0` and `9`.

  ## Examples

      iex> NeoFaker.Number.digit()
      5

  """
  @spec digit() :: integer()
  def digit, do: Enum.random(0..9)
end
