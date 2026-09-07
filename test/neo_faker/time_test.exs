defmodule NeoFaker.TimeTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Time, as: FakeTime
  alias NeoFaker.Time.Generator
  alias NeoFaker.Time.Validator

  defp local_time, do: NaiveDateTime.to_time(NaiveDateTime.local_now())

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

  defp assert_between(time, lo, hi) do
    assert Time.compare(time, lo) != :lt
    assert Time.compare(time, hi) != :gt
  end

  describe "add/2" do
    test "returns a Time struct by default" do
      assert %Time{} = FakeTime.add(0..0)
    end

    test "returns a Time struct for every supported unit" do
      for unit <- [:hour, :minute, :second] do
        assert %Time{} = FakeTime.add(0..0, unit: unit)
      end
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      assert FakeTime.add(0..0, format: :iso8601) =~ ~r/^\d{2}:\d{2}:\d{2}$/
    end

    test "raises ArgumentError for a descending range" do
      assert_raise ArgumentError, ~r/first must be less than or equal to last/, fn ->
        FakeTime.add(10..1//-1)
      end
    end

    test "raises ArgumentError for a non-range" do
      assert_raise ArgumentError, ~r/Expected a Range/, fn -> FakeTime.add(opaque(:noon)) end
    end

    test "raises NimbleOptions.ValidationError for an unknown unit" do
      assert_raise NimbleOptions.ValidationError, fn -> FakeTime.add(0..0, unit: :day) end
    end
  end

  describe "between/3" do
    test "returns the exact time when start and finish are equal" do
      now = local_time()

      assert FakeTime.between(now, now) == now
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      now = local_time()

      assert FakeTime.between(now, now, format: :iso8601) == Time.to_iso8601(now)
    end

    test "returns a time within the given bounds" do
      assert_between(FakeTime.between(~T[08:00:00], ~T[18:00:00]), ~T[08:00:00], ~T[18:00:00])
    end

    test "uses the full day as the default bounds" do
      assert_between(FakeTime.between(), ~T[00:00:00], ~T[23:59:59])
    end

    test "raises ArgumentError when start is after finish" do
      assert_raise ArgumentError, ~r/start time must be before or equal to finish time/, fn ->
        FakeTime.between(~T[18:00:00], ~T[08:00:00])
      end
    end
  end

  describe "time_zone/0" do
    test "returns a value from the known IANA time zone list" do
      zones = :default |> Data.fetch!(FakeTime, "time_zone.exs") |> Map.fetch!("time_zone")

      assert FakeTime.time_zone() in zones
    end
  end

  describe "named period helpers" do
    test "morning/1 stays within 06:00..11:59" do
      assert_between(FakeTime.morning(), ~T[06:00:00], ~T[11:59:59])
    end

    test "afternoon/1 stays within 12:00..17:59" do
      assert_between(FakeTime.afternoon(), ~T[12:00:00], ~T[17:59:59])
    end

    test "evening/1 stays within 18:00..23:59" do
      assert_between(FakeTime.evening(), ~T[18:00:00], ~T[23:59:59])
    end

    test "night/1 stays within 00:00..05:59" do
      assert_between(FakeTime.night(), ~T[00:00:00], ~T[05:59:59])
    end

    test "each helper honours format: :iso8601" do
      for helper <- [:morning, :afternoon, :evening, :night] do
        assert apply(FakeTime, helper, [[format: :iso8601]]) =~ ~r/^\d{2}:\d{2}:\d{2}$/
      end
    end
  end

  describe "now/1" do
    test "returns the current time as a struct" do
      assert %Time{} = FakeTime.now()
    end

    test "returns the current time as an ISO 8601 string" do
      assert FakeTime.now(format: :iso8601) =~ ~r/^\d{2}:\d{2}:\d{2}/
    end
  end

  describe "Generator" do
    test "add/3 returns a struct or an ISO 8601 string" do
      assert %Time{} = Generator.add(0..0, :second, :struct)
      assert Generator.add(0..0, :second, :iso8601) =~ ~r/^\d{2}:\d{2}:\d{2}$/
    end

    test "between/3 returns a struct or an ISO 8601 string" do
      assert %Time{} = Generator.between(~T[08:00:00], ~T[09:00:00], :struct)
      assert Generator.between(~T[08:00:00], ~T[08:00:00], :iso8601) == "08:00:00"
    end
  end

  describe "Validator" do
    test "validate_range!/1 accepts an ascending range" do
      assert Validator.validate_range!(1..10) == :ok
    end

    test "validate_time_order!/2 accepts equal times" do
      assert Validator.validate_time_order!(~T[08:00:00], ~T[08:00:00]) == :ok
    end
  end
end
