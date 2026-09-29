defmodule NeoFaker.TimeTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Time, as: FakeTime
  alias NeoFaker.Time.Generator
  alias NeoFaker.Time.Validator

  defp utc_time, do: Time.utc_now()

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

    test "returns a time at second precision" do
      assert %Time{microsecond: {0, 0}} = FakeTime.add()
    end

    test "offsets from the current UTC time" do
      now = Time.truncate(FakeTime.now(), :second)
      result = FakeTime.add(0..0, unit: :second)

      # Allow for the clock ticking over between the two reads.
      assert Time.diff(result, now) in [0, 1, -86_399]
    end

    test "raises ArgumentError for an empty range" do
      assert_raise ArgumentError, ~r/range must be a non-empty range/, fn ->
        FakeTime.add(1..10//-1)
      end
    end

    test "raises ArgumentError for a non-range" do
      assert_raise ArgumentError, ~r/range must be a range/, fn -> FakeTime.add(opaque(:noon)) end
    end

    test "raises NimbleOptions.ValidationError for an unknown unit" do
      assert_raise NimbleOptions.ValidationError, fn -> FakeTime.add(0..0, unit: :day) end
    end

    test "raises NimbleOptions.ValidationError for the removed :format option" do
      assert_raise NimbleOptions.ValidationError, fn -> FakeTime.add(0..0, format: :iso8601) end
    end
  end

  describe "between/2" do
    test "returns the exact time when start and finish are equal" do
      now = utc_time()

      assert FakeTime.between(now, now) == now
    end

    test "returns a time within the given bounds" do
      assert_between(FakeTime.between(~T[08:00:00], ~T[18:00:00]), ~T[08:00:00], ~T[18:00:00])
    end

    test "never overshoots sub-second bounds" do
      for _ <- 1..200 do
        assert_between(
          FakeTime.between(~T[10:00:00.900000], ~T[10:00:01.100000]),
          ~T[10:00:00.900000],
          ~T[10:00:01.100000]
        )
      end
    end

    test "keeps second precision for whole-second bounds" do
      assert %Time{microsecond: {0, 0}} = FakeTime.between(~T[08:00:00], ~T[18:00:00])
    end

    test "raises ArgumentError for a non-Time argument" do
      assert_raise ArgumentError, ~r/must be Time structs/, fn ->
        FakeTime.between(opaque("08:00:00"), ~T[18:00:00])
      end
    end

    test "uses the full day as the default bounds" do
      assert_between(FakeTime.between(), ~T[00:00:00], ~T[23:59:59])
    end

    test "raises ArgumentError when start is after finish" do
      assert_raise ArgumentError, ~r/start time must be at or before finish time/, fn ->
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
    test "morning/0 stays within 06:00..11:59" do
      assert_between(FakeTime.morning(), ~T[06:00:00], ~T[11:59:59])
    end

    test "afternoon/0 stays within 12:00..17:59" do
      assert_between(FakeTime.afternoon(), ~T[12:00:00], ~T[17:59:59])
    end

    test "evening/0 stays within 18:00..23:59" do
      assert_between(FakeTime.evening(), ~T[18:00:00], ~T[23:59:59])
    end

    test "night/0 stays within 00:00..05:59" do
      assert_between(FakeTime.night(), ~T[00:00:00], ~T[05:59:59])
    end
  end

  describe "now/0" do
    test "returns the current time as a struct" do
      assert %Time{} = FakeTime.now()
    end
  end

  describe "Generator" do
    test "add/2 returns a Time struct" do
      assert %Time{} = Generator.add(0..0, :second)
    end

    test "between/2 returns a Time struct within bounds" do
      assert %Time{} = Generator.between(~T[08:00:00], ~T[09:00:00])
      assert Generator.between(~T[08:00:00], ~T[08:00:00]) == ~T[08:00:00]
    end
  end

  describe "Validator" do
    test "validate_time_order!/2 accepts equal times" do
      assert Validator.validate_time_order!(~T[08:00:00], ~T[08:00:00]) == :ok
    end
  end
end
