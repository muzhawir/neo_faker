defmodule NeoFaker.TimeTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Time, as: FakeTime

  defp local_time, do: NaiveDateTime.to_time(NaiveDateTime.local_now())

  describe "add/2" do
    test "returns a Time struct when adding 0 seconds" do
      result = FakeTime.add(0..0)

      assert %Time{} = result
    end

    test "returns a Time struct for each supported unit" do
      for unit <- [:hour, :minute, :second] do
        result = FakeTime.add(0..0, unit: unit)

        assert %Time{} = result
      end
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      result = FakeTime.add(0..0, format: :iso8601)

      assert is_binary(result)
      assert String.match?(result, ~r/^\d{2}:\d{2}:\d{2}/)
    end

    test "returns a time within a reasonable range when adding positive seconds" do
      before = Time.add(local_time(), -1, :second)
      result = FakeTime.add(0..60, unit: :second)
      after_time = Time.add(local_time(), 61, :second)

      assert Time.compare(result, before) != :lt
      assert Time.compare(result, after_time) != :gt
    end
  end

  describe "between/3" do
    test "returns the exact time when start and finish are the same" do
      now = local_time()

      assert FakeTime.between(now, now) == now
    end

    test "returns an ISO 8601 string when format: :iso8601" do
      now = local_time()

      assert FakeTime.between(now, now, format: :iso8601) == Time.to_iso8601(now)
    end

    test "returns a time between the given start and finish" do
      start_time = ~T[08:00:00]
      finish_time = ~T[18:00:00]
      result = FakeTime.between(start_time, finish_time)

      assert Time.compare(result, start_time) != :lt
      assert Time.compare(result, finish_time) != :gt
    end
  end

  describe "time_zone/0" do
    test "returns a string from the known time zone list" do
      time_zone_list =
        :default
        |> Data.fetch!(FakeTime, "time_zone.exs")
        |> Map.get("time_zone")

      assert FakeTime.time_zone() in time_zone_list
    end
  end
end
