defmodule NeoFaker.Number do
  @moduledoc """
  Functions for generating random numbers.

  This module provides utilities to generate random numbers, including values within a specified
  range.
  """
  @moduledoc since: "0.8.0"

  @doc """
  Generates a random number between `min` and `max`.

  Returns a random integer when both arguments are integers, or a random float when either
  argument is a float. If no arguments are given, returns a random value in the range 0 to 100.

  ## Examples

      iex> NeoFaker.Number.between()
      27

      iex> NeoFaker.Number.between(1, 100)
      28

      iex> NeoFaker.Number.between(20, 100.0)
      29.481745280074264

      iex> NeoFaker.Number.between(10.0, 100.0)
      29.481745280074264

  """
  @spec between(number(), number()) :: number()
  def between(min \\ 0, max \\ 100)
  def between(min, max) when is_integer(min) and is_integer(max), do: Enum.random(min..max)

  def between(min, max) when is_float(min) and is_float(max) do
    :rand.uniform() * (max - min) + min
  end

  def between(min, max) do
    between(min + 0.0, max + 0.0)
  end

  @doc """
  Generates a random floating-point number within the given range.

  Returns a floating-point number composed of a randomly selected integer part and a fractional
  part. The integer part is chosen from the `left_digit` range, and the fractional part is
  composed of digits chosen from the `right_digit` range. If no arguments are given, defaults to
  a left digit in the range `10..100` and a right digit in the range `10_000..100_000`.

  ## Examples

      iex> NeoFaker.Number.float()
      30.94372

      iex> NeoFaker.Number.float(1..9, 10..90)
      1.44

  """
  @spec float(Range.t(), Range.t()) :: float()
  def float(left_digit \\ 10..100, right_digit \\ 10_000..100_000) do
    String.to_float("#{Enum.random(left_digit)}.#{Enum.random(right_digit)}")
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
