defmodule NeoFaker.NumberTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Number
  alias NeoFaker.Number.Generator
  alias NeoFaker.Number.Validator

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

  describe "between/2" do
    test "returns an integer within the range when both bounds are integers" do
      assert Number.between(10, 20) in 10..20
    end

    test "returns the default 0..100 integer range" do
      assert Number.between() in 0..100
    end

    test "returns a float when both bounds are floats" do
      result = Number.between(1.0, 100.0)

      assert is_float(result)
      assert result >= 1.0 and result <= 100.0
    end

    test "coerces mixed integer/float bounds to a float" do
      assert is_float(Number.between(20, 100.0))
      assert is_float(Number.between(20.0, 100))
    end

    test "returns the exact value when min equals max" do
      assert Number.between(50, 50) == 50
      assert Number.between(50.0, 50.0) == 50.0
    end

    test "raises ArgumentError when min is greater than max" do
      assert_raise ArgumentError, ~r/min must be less than or equal to max/, fn ->
        Number.between(100, 1)
      end
    end
  end

  describe "float/2" do
    test "returns a float with default ranges" do
      assert is_float(Number.float())
    end

    test "returns a float with custom ranges" do
      assert is_float(Number.float(1..9, 10..90))
    end

    test "accepts descending ranges with a negative step" do
      assert is_float(Number.float(10..5//-1, 100..10//-1))
    end

    test "raises ArgumentError for an empty left_digit range" do
      assert_raise ArgumentError, ~r/left_digit must be a non-empty range/, fn ->
        Number.float(5..10//-1, 10..100)
      end
    end

    test "raises ArgumentError when right_digit contains a negative number" do
      assert_raise ArgumentError, ~r/right_digit must only contain non-negative integers/, fn ->
        Number.float(1..9, -5..5)
      end

      assert_raise ArgumentError, ~r/right_digit must only contain non-negative integers/, fn ->
        Number.float(1..9, 5..-5//-1)
      end
    end
  end

  describe "digit/0" do
    test "returns an integer between 0 and 9" do
      assert Number.digit() in 0..9
    end
  end

  describe "positive/1" do
    test "returns a positive integer within the default max" do
      assert Number.positive() in 1..100
    end

    test "returns a positive integer within the given max" do
      assert Number.positive(10) in 1..10
    end

    test "raises ArgumentError when max is below 1" do
      assert_raise ArgumentError, ~r/max must be a positive integer/, fn -> Number.positive(0) end
    end
  end

  describe "negative/1" do
    test "returns a negative integer within the default min" do
      assert Number.negative() in -100..-1
    end

    test "returns a negative integer within the given min" do
      assert Number.negative(-10) in -10..-1
    end

    test "raises ArgumentError when min is above -1" do
      assert_raise ArgumentError, ~r/min must be a negative integer/, fn -> Number.negative(0) end
    end
  end

  describe "decimal/3" do
    test "rounds to 2 decimal places by default and stays within range" do
      result = Number.decimal()

      assert is_float(result)
      assert result >= 0.0 and result <= 100.0
    end

    test "rounds to the requested precision" do
      decimal_places =
        0.0
        |> Number.decimal(1.0, 4)
        |> Float.to_string()
        |> String.split(".")
        |> List.last()
        |> String.length()

      assert decimal_places <= 4
    end

    test "accepts integer and mixed bounds and returns a float" do
      assert is_float(Number.decimal(0, 10, 2))
      assert is_float(Number.decimal(0, 100.0, 2))
    end

    test "returns min when min and max are equal" do
      assert Number.decimal(5.0, 5.0) == 5.0
    end

    test "raises ArgumentError when min is greater than max" do
      assert_raise ArgumentError, ~r/min must be less than or equal to max/, fn ->
        Number.decimal(100.0, 0.0)
      end
    end

    test "raises ArgumentError when precision is outside 0..15" do
      assert_raise ArgumentError, ~r/precision must be an integer between 0 and 15/, fn ->
        Number.decimal(0.0, 10.0, -1)
      end

      assert_raise ArgumentError, ~r/precision must be an integer between 0 and 15/, fn ->
        Number.decimal(0.0, 10.0, 16)
      end
    end

    test "draws a float even when both bounds are integers" do
      results = for _ <- 1..50, do: Number.decimal(0, 10, 3)

      assert Enum.all?(results, &is_float/1)
      assert Enum.any?(results, &(&1 != Float.round(&1)))
    end

    test "raises ArgumentError for a non-numeric bound" do
      assert_raise ArgumentError, ~r/min and max must be numbers/, fn ->
        Number.decimal(Enum.random(["0"]), 10.0)
      end
    end
  end

  describe "Generator" do
    test "float_between/2 returns min when the bounds are equal" do
      assert Generator.float_between(3.5, 3.5) == 3.5
    end

    test "float_between/2 returns a value in [min, max) otherwise" do
      result = Generator.float_between(1.0, 2.0)

      assert result >= 1.0 and result < 2.0
    end

    test "float_between/2 does not overflow near the float limits" do
      result = Generator.float_between(-1.0e308, 1.0e308)

      assert result >= -1.0e308 and result <= 1.0e308
    end

    test "to_float/1 coerces integers and leaves floats untouched" do
      assert Generator.to_float(3) === 3.0
      assert Generator.to_float(3.5) === 3.5
    end
  end

  describe "Validator" do
    test "validate_fraction_range!/1 returns a valid range unchanged" do
      assert Validator.validate_fraction_range!(0..10) == 0..10
    end

    test "validate_precision!/1 accepts 0..15 only" do
      assert Validator.validate_precision!(15) == :ok
      assert_raise ArgumentError, fn -> Validator.validate_precision!(opaque(1.5)) end
    end
  end
end
