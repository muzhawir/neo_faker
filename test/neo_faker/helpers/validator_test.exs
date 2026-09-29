defmodule NeoFaker.Helpers.ValidatorTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helpers.Validator

  defp opaque(term), do: Enum.random([term])

  describe "validate_range!/2" do
    test "returns ascending, descending, and stepped non-empty ranges unchanged" do
      for range <- [1..10, 10..1//-1, 0..10//5, 3..3] do
        assert Validator.validate_range!(range, "range") == range
      end
    end

    test "raises ArgumentError for an empty range" do
      assert_raise ArgumentError, "days must be a non-empty range, got: 1..10//-1", fn ->
        Validator.validate_range!(1..10//-1, "days")
      end
    end

    test "raises ArgumentError for a non-range" do
      assert_raise ArgumentError, "days must be a range, got: [1, 2]", fn ->
        Validator.validate_range!(opaque([1, 2]), "days")
      end
    end
  end

  describe "validate_range_option/1" do
    test "accepts a non-empty range and rejects anything else" do
      assert Validator.validate_range_option(1..5) == {:ok, 1..5}
      assert {:error, _} = Validator.validate_range_option(5..1//1)
      assert {:error, _} = Validator.validate_range_option(:nope)
    end
  end

  describe "validate_non_neg_bounds!/3" do
    @names {"min", "max"}

    test "accepts ordered non-negative integers" do
      assert Validator.validate_non_neg_bounds!(0, 0, @names) == :ok
      assert Validator.validate_non_neg_bounds!(1, 5, @names) == :ok
    end

    test "rejects negative, non-integer, and inverted bounds" do
      assert_raise ArgumentError, ~r/min must be a non-negative integer/, fn ->
        Validator.validate_non_neg_bounds!(-1, 5, @names)
      end

      assert_raise ArgumentError, ~r/max must be a non-negative integer/, fn ->
        Validator.validate_non_neg_bounds!(1, opaque(5.0), @names)
      end

      assert_raise ArgumentError,
                   "min must be less than or equal to max, got: min=6, max=5",
                   fn ->
                     Validator.validate_non_neg_bounds!(6, 5, @names)
                   end
    end
  end
end
