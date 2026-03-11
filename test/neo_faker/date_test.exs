defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate

  defp today, do: NaiveDateTime.to_date(NaiveDateTime.local_now())

  describe "add/2" do
    test "returns a Date struct when adding 0 days" do
      before = today()
      result = FakeDate.add(0..0)
      after_date = today()

      assert %Date{} = result
      assert Date.compare(result, before) != :lt
      assert Date.compare(result, after_date) != :gt
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      before = today()
      result = FakeDate.add(0..0, format: :iso8601)
      after_date = today()

      assert {:ok, parsed} = Date.from_iso8601(result)
      assert Date.compare(parsed, before) != :lt
      assert Date.compare(parsed, after_date) != :gt
    end

    test "returns a date within a positive range from today" do
      before = today()
      result = FakeDate.add(0..30)
      after_date = today()

      assert %Date{} = result
      assert Date.compare(result, before) != :lt
      assert Date.compare(result, Date.add(after_date, 30)) != :gt
    end

    test "returns a date within a negative range from today" do
      before = today()
      result = FakeDate.add(-30..0)
      after_date = today()

      assert %Date{} = result
      assert Date.compare(result, Date.add(before, -30)) != :lt
      assert Date.compare(result, after_date) != :gt
    end
  end

  describe "between/3" do
    test "returns a Date struct equal to today when start and end are the same" do
      before = today()
      result = FakeDate.between(before, before)
      after_date = today()

      assert %Date{} = result
      assert Date.compare(result, before) != :lt
      assert Date.compare(result, after_date) != :gt
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      before = today()
      result = FakeDate.between(before, before, format: :iso8601)
      after_date = today()

      assert {:ok, parsed} = Date.from_iso8601(result)
      assert Date.compare(parsed, before) != :lt
      assert Date.compare(parsed, after_date) != :gt
    end

    test "returns a date between the given start and end dates" do
      start_date = ~D[2020-01-01]
      end_date = ~D[2020-12-31]
      result = FakeDate.between(start_date, end_date)

      assert %Date{} = result
      assert Date.compare(result, start_date) != :lt
      assert Date.compare(result, end_date) != :gt
    end
  end

  describe "birthday/3" do
    test "returns a Date struct" do
      assert %Date{} = FakeDate.birthday(18, 65)
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      result = FakeDate.birthday(18, 65, format: :iso8601)

      assert String.match?(result, ~r/^\d{4}-\d{2}-\d{2}$/)
    end

    test "result falls within the 18..65 age window" do
      before = today()
      result = FakeDate.birthday(18, 65)
      after_date = today()

      lower = before |> Date.shift(year: -66) |> Date.add(1)
      upper = Date.shift(after_date, year: -18)

      refute Date.before?(result, lower),
             "#{result} is before lower bound #{lower} (before=#{before})"

      refute Date.after?(result, upper),
             "#{result} is after upper bound #{upper} (after_date=#{after_date})"
    end

    test "lower bound is one day after today shifted back by max_age+1 years" do
      max_age = 30
      # Capture before/after around the entire loop so that the expected_lower
      # bound and all birthday/3 calls inside use a consistent date.
      before = today()

      results = for _ <- 1..30, do: FakeDate.birthday(max_age, max_age)

      after_date = today()

      # The lower bound is derived from before (the earliest possible "today"
      # that the function could have seen), giving the widest valid window.
      expected_lower = before |> Date.shift(year: -(max_age + 1)) |> Date.add(1)

      # The upper bound is derived from after_date (the latest possible "today").
      expected_upper = Date.shift(after_date, year: -max_age)

      for result <- results do
        refute Date.before?(result, expected_lower),
               "#{result} is before lower bound #{expected_lower} for max_age=#{max_age}"

        refute Date.after?(result, expected_upper),
               "#{result} is after upper bound #{expected_upper} for max_age=#{max_age}"
      end
    end

    test "upper bound is today shifted back by min_age years" do
      min_age = 18

      before = today()
      results = for _ <- 1..30, do: FakeDate.birthday(min_age, min_age)
      after_date = today()

      expected_lower = before |> Date.shift(year: -(min_age + 1)) |> Date.add(1)
      expected_upper = Date.shift(after_date, year: -min_age)

      for result <- results do
        refute Date.before?(result, expected_lower),
               "#{result} is before lower bound #{expected_lower} for min_age=#{min_age}"

        refute Date.after?(result, expected_upper),
               "#{result} is after upper bound #{expected_upper} for min_age=#{min_age}"
      end
    end

    test "result falls within the full age window for default min/max" do
      before = today()
      result = FakeDate.birthday()
      after_date = today()

      lower = before |> Date.shift(year: -66) |> Date.add(1)
      upper = Date.shift(after_date, year: -18)

      refute Date.before?(result, lower),
             "#{result} is before lower bound #{lower}"

      refute Date.after?(result, upper),
             "#{result} is after upper bound #{upper}"
    end

    test "window covers exactly one year when min_age equals max_age" do
      age = 25
      snapshot = today()
      lower = snapshot |> Date.shift(year: -(age + 1)) |> Date.add(1)
      upper = Date.shift(snapshot, year: -age)

      assert Date.diff(upper, lower) in 364..365,
             "expected window of ~365 days for age=#{age}, got #{Date.diff(upper, lower)}"
    end

    test "birthday(0, 0) returns a date within the last year" do
      before = today()
      result = FakeDate.birthday(0, 0)
      after_date = today()

      lower = before |> Date.shift(year: -1) |> Date.add(1)

      refute Date.before?(result, lower),
             "#{result} is before lower bound #{lower} for age=0"

      refute Date.after?(result, after_date),
             "#{result} is after after_date=#{after_date} for age=0"
    end
  end
end
