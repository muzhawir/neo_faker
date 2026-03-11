defmodule NeoFaker.NumberTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Number

  describe "between/2" do
    test "returns a random integer with default range" do
      assert is_integer(Number.between())
    end

    test "returns a random integer within the specified range" do
      result = Number.between(10, 20)

      assert is_integer(result)
      assert result in 10..20
    end

    test "returns a random float when arguments are floats" do
      assert is_float(Number.between(1.0, 100.0))
    end

    test "returns the exact value when min equals max" do
      assert Number.between(50, 50) == 50
    end

    test "raises ArgumentError when min is greater than max" do
      assert_raise ArgumentError, fn ->
        Number.between(100, 1)
      end
    end
  end

  describe "float/2" do
    test "returns a random floating-point number with default ranges" do
      assert is_float(Number.float())
    end

    test "returns a random floating-point number with specified ranges" do
      assert is_float(Number.float(1..100, 100..1000))
    end
  end

  describe "digit/0" do
    test "returns a random digit between 0 and 9" do
      digit = Number.digit()

      assert is_integer(digit)
      assert digit in 0..9
    end
  end

  describe "positive/1" do
    test "returns a random positive integer with default max" do
      result = Number.positive()

      assert is_integer(result)
      assert result >= 1
    end

    test "returns a random positive integer within the specified max" do
      result = Number.positive(10)

      assert is_integer(result)
      assert result in 1..10
    end

    test "raises ArgumentError when max is less than 1" do
      assert_raise ArgumentError, fn ->
        Number.positive(0)
      end
    end
  end

  describe "negative/1" do
    test "returns a random negative integer with default min" do
      result = Number.negative()

      assert is_integer(result)
      assert result <= -1
    end

    test "returns a random negative integer within the specified min" do
      result = Number.negative(-10)

      assert is_integer(result)
      assert result in -10..-1
    end

    test "raises ArgumentError when min is greater than -1" do
      assert_raise ArgumentError, fn ->
        Number.negative(0)
      end
    end
  end

  describe "decimal/3" do
    test "returns a random float rounded to 2 decimal places by default" do
      result = Number.decimal()

      assert is_float(result)
      assert result >= 0.0 and result <= 100.0
    end

    test "returns a random float rounded to the specified precision" do
      result = Number.decimal(0.0, 1.0, 4)

      assert is_float(result)

      decimal_places =
        result
        |> Float.to_string()
        |> String.split(".")
        |> List.last()
        |> String.length()

      assert decimal_places <= 4
    end
  end
end
