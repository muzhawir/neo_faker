defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate
  alias NeoFaker.Date.Generator
  alias NeoFaker.Date.Validator

  defp today, do: NaiveDateTime.to_date(NaiveDateTime.local_now())

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

  describe "add/2" do
    test "returns today's date when the range is 0..0" do
      before = today()
      result = FakeDate.add(0..0)

      assert %Date{} = result
      assert Date.compare(result, before) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      result = FakeDate.add(0..0, format: :iso8601)

      assert {:ok, _} = Date.from_iso8601(result)
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

    test "raises NimbleOptions.ValidationError for an unknown format" do
      assert_raise NimbleOptions.ValidationError, fn -> FakeDate.add(0..0, format: :rfc3339) end
    end
  end

  describe "between/3" do
    test "returns a Date struct within the given bounds" do
      result = FakeDate.between(~D[2020-01-01], ~D[2020-12-31])

      assert Date.compare(result, ~D[2020-01-01]) != :lt
      assert Date.compare(result, ~D[2020-12-31]) != :gt
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      result = FakeDate.between(~D[2020-01-01], ~D[2020-01-01], format: :iso8601)

      assert result == "2020-01-01"
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

  describe "birthday/3" do
    test "returns a Date struct within the requested age window" do
      before = today()
      result = FakeDate.birthday(18, 65)

      lower = before |> Date.shift(year: -66) |> Date.add(1)
      upper = Date.shift(today(), year: -18)

      refute Date.before?(result, lower)
      refute Date.after?(result, upper)
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert FakeDate.birthday(18, 65, format: :iso8601) =~ ~r/^\d{4}-\d{2}-\d{2}$/
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

  describe "past/2" do
    test "returns a date between `days` ago and today" do
      before = today()
      result = FakeDate.past(30)

      assert Date.compare(result, Date.add(before, -30)) != :lt
      assert Date.compare(result, today()) != :gt
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert {:ok, _} = Date.from_iso8601(FakeDate.past(365, format: :iso8601))
    end

    test "raises FunctionClauseError for a non-positive day count" do
      assert_raise FunctionClauseError, fn -> FakeDate.past(0) end
    end
  end

  describe "future/2" do
    test "returns a date between today and `days` from now" do
      before = today()
      result = FakeDate.future(30)

      assert Date.compare(result, before) != :lt
      assert Date.compare(result, Date.add(today(), 30)) != :gt
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert {:ok, _} = Date.from_iso8601(FakeDate.future(365, format: :iso8601))
    end

    test "raises FunctionClauseError for a non-positive day count" do
      assert_raise FunctionClauseError, fn -> FakeDate.future(-1) end
    end
  end

  describe "today/1" do
    test "returns today's date as a struct" do
      assert FakeDate.today() == today()
    end

    test "returns today's date as an ISO 8601 string" do
      assert FakeDate.today(format: :iso8601) == Date.to_iso8601(today())
    end
  end

  describe "Generator" do
    test "add/2 returns a struct or an ISO 8601 string" do
      assert %Date{} = Generator.add(0..0, :struct)
      assert Generator.add(0..0, :iso8601) == Date.to_iso8601(today())
    end

    test "between/3 returns a struct or an ISO 8601 string" do
      assert %Date{} = Generator.between(~D[2020-01-01], ~D[2020-01-01], :struct)
      assert Generator.between(~D[2020-01-01], ~D[2020-01-01], :iso8601) == "2020-01-01"
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
