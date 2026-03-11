defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate

  defp today, do: NaiveDateTime.to_date(NaiveDateTime.local_now())
  defp today_iso, do: Date.to_iso8601(today())

  describe "add/2" do
    test "returns a Date struct when adding 0 days" do
      assert FakeDate.add(0..0) == today()
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert FakeDate.add(0..0, format: :iso8601) == today_iso()
    end

    test "returns a date within a positive range from today" do
      result = FakeDate.add(0..30)

      assert %Date{} = result
      assert Date.compare(result, today()) != :lt
      assert Date.compare(result, Date.add(today(), 30)) != :gt
    end

    test "returns a date within a negative range from today" do
      result = FakeDate.add(-30..0)

      assert %Date{} = result
      assert Date.compare(result, Date.add(today(), -30)) != :lt
      assert Date.compare(result, today()) != :gt
    end
  end

  describe "between/3" do
    test "returns a Date struct equal to today when start and end are the same" do
      assert FakeDate.between(today(), today()) == today()
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert FakeDate.between(today(), today(), format: :iso8601) == today_iso()
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
    test "returns today when min and max age are both 0" do
      assert FakeDate.birthday(0, 0) == today()
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert FakeDate.birthday(0, 0, format: :iso8601) == today_iso()
    end

    test "returns a date in the past for a positive age range" do
      result = FakeDate.birthday(18, 30)

      assert %Date{} = result
      assert Date.before?(result, today())
    end
  end
end
