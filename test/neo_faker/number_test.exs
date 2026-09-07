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

    test "raises ArgumentError when the left_digit range is descending" do
      assert_raise ArgumentError, ~r/left_digit range must have first <= last/, fn ->
        Number.float(10..5//-1, 10..100)
      end
    end

    test "raises ArgumentError when the right_digit range is descending" do
      assert_raise ArgumentError, ~r/right_digit range must have first <= last/, fn ->
        Number.float(1..9, 100..10//-1)
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
      assert_raise ArgumentError, ~r/max must be at least 1/, fn -> Number.positive(0) end
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
      assert_raise ArgumentError, ~r/min must be at most -1/, fn -> Number.negative(0) end
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

    test "raises ArgumentError when precision is negative" do
      assert_raise ArgumentError, ~r/precision must be greater than or equal to 0/, fn ->
        Number.decimal(0.0, 10.0, -1)
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

    test "to_float/1 coerces integers and leaves floats untouched" do
      assert Generator.to_float(3) === 3.0
      assert Generator.to_float(3.5) === 3.5
    end
  end

  describe "Validator.validate_range!/2" do
    test "returns :ok for an ascending range" do
      assert Validator.validate_range!(1..10, "left_digit") == :ok
    end

    test "raises ArgumentError for a descending range, naming the argument" do
      assert_raise ArgumentError, ~r/^right_digit range must have first <= last/, fn ->
        Validator.validate_range!(10..1//-1, "right_digit")
      end
    end

    test "raises ArgumentError for a non-range value, naming the argument" do
      assert_raise ArgumentError, ~r/^left_digit must be a Range/, fn ->
        Validator.validate_range!(opaque([1, 10]), "left_digit")
      end
    end
  end
end
