defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate
  alias NeoFaker.Date.Generator
  alias NeoFaker.Date.Validator

  defp today, do: NaiveDateTime.to_date(NaiveDateTime.local_now())

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

  describe "add/1" do
    test "returns today's date when the range is 0..0" do
      before = today()
      result = FakeDate.add(0..0)

      assert %Date{} = result
      assert Date.compare(result, before) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "stays within a positive range from today" do
      before = today()
      result = FakeDate.add(0..30)

      assert Date.compare(result, before) != :lt
      assert Date.compare(result, Date.add(today(), 30)) != :gt
    end

    test "stays within a negative range from today" do
      before = today()
      result = FakeDate.add(-30..0)

      assert Date.compare(result, Date.add(before, -30)) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "uses the default -365..365 range" do
      before = today()
      result = FakeDate.add()

      assert Date.compare(result, Date.add(before, -365)) != :lt
      assert Date.compare(result, Date.add(today(), 365)) != :gt
    end

    test "raises ArgumentError for a descending range" do
      assert_raise ArgumentError, ~r/first must be less than or equal to last/, fn ->
        FakeDate.add(10..1//-1)
      end
    end

    test "raises ArgumentError for a non-range" do
      assert_raise ArgumentError, ~r/Expected a Range/, fn ->
        FakeDate.add(opaque([1, 2, 3]))
      end
    end
  end

  describe "between/2" do
    test "returns a Date struct within the given bounds" do
      result = FakeDate.between(~D[2020-01-01], ~D[2020-12-31])

      assert Date.compare(result, ~D[2020-01-01]) != :lt
      assert Date.compare(result, ~D[2020-12-31]) != :gt
    end

    test "returns the exact date when start equals finish" do
      assert FakeDate.between(~D[2020-01-01], ~D[2020-01-01]) == ~D[2020-01-01]
    end

    test "uses the epoch and today as defaults" do
      result = FakeDate.between()

      assert Date.compare(result, ~D[1970-01-01]) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "raises ArgumentError when start is after finish" do
      assert_raise ArgumentError, ~r/start date must be before or equal to finish date/, fn ->
        FakeDate.between(~D[2025-01-01], ~D[2020-01-01])
      end
    end
  end

  describe "birthday/2" do
    test "returns a Date struct within the requested age window" do
      before = today()
      result = FakeDate.birthday(18, 65)

      lower = before |> Date.shift(year: -66) |> Date.add(1)
      upper = Date.shift(today(), year: -18)

      refute Date.before?(result, lower)
      refute Date.after?(result, upper)
    end

    test "uses the default 18..65 window" do
      assert %Date{} = FakeDate.birthday()
    end

    test "raises ArgumentError when min_age is negative" do
      assert_raise ArgumentError, ~r/min_age must be non-negative/, fn ->
        FakeDate.birthday(-1, 65)
      end
    end

    test "raises ArgumentError when max_age is negative" do
      assert_raise ArgumentError, ~r/max_age must be non-negative/, fn ->
        FakeDate.birthday(0, -1)
      end
    end

    test "raises ArgumentError when min_age exceeds max_age" do
      assert_raise ArgumentError, ~r/min_age must be less than or equal to max_age/, fn ->
        FakeDate.birthday(65, 18)
      end
    end

    test "raises ArgumentError when an age is not an integer" do
      assert_raise ArgumentError, ~r/min_age must be an integer/, fn ->
        FakeDate.birthday(opaque(:young), 65)
      end

      assert_raise ArgumentError, ~r/max_age must be an integer/, fn ->
        FakeDate.birthday(18, opaque(:old))
      end
    end
  end

  describe "past/1" do
    test "defaults to the last 365 days" do
      result = FakeDate.past()

      assert Date.compare(result, Date.add(today(), -365)) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "returns a date between `days` ago and today" do
      before = today()
      result = FakeDate.past(30)

      assert Date.compare(result, Date.add(before, -30)) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "raises ArgumentError for a non-positive day count" do
      assert_raise ArgumentError, ~r/days must be a positive integer/, fn -> FakeDate.past(0) end
    end
  end

  describe "future/1" do
    test "defaults to the next 365 days" do
      result = FakeDate.future()

      assert Date.compare(result, today()) != :lt
      assert Date.compare(result, Date.add(today(), 365)) != :gt
    end

    test "returns a date between today and `days` from now" do
      before = today()
      result = FakeDate.future(30)

      assert Date.compare(result, before) != :lt
      assert Date.compare(result, Date.add(today(), 30)) != :gt
    end

    test "raises ArgumentError for a non-positive day count" do
      assert_raise ArgumentError, ~r/days must be a positive integer/, fn ->
        FakeDate.future(-1)
      end
    end
  end

  describe "today/0" do
    test "returns today's date as a struct" do
      assert FakeDate.today() == today()
    end
  end

  describe "Generator" do
    test "add/1 returns a Date struct" do
      assert %Date{} = Generator.add(0..0)
      assert Generator.add(0..0) == today()
    end

    test "between/2 returns a Date struct within bounds" do
      assert Generator.between(~D[2020-01-01], ~D[2020-01-01]) == ~D[2020-01-01]
      assert %Date{} = Generator.between(~D[2020-01-01], ~D[2020-12-31])
    end

    test "local_date_now/0 returns today" do
      assert Generator.local_date_now() == today()
    end
  end

  describe "Validator" do
    test "validate_range!/1 accepts an ascending range" do
      assert Validator.validate_range!(1..10) == :ok
    end

    test "validate_date_order!/2 accepts equal dates" do
      assert Validator.validate_date_order!(~D[2020-01-01], ~D[2020-01-01]) == :ok
    end

    test "validate_age_range!/2 accepts a valid window" do
      assert Validator.validate_age_range!(18, 65) == :ok
    end
  end
end
