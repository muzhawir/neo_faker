defmodule NeoFaker.TimeTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data.Cache
  alias NeoFaker.Time, as: FakeTime

  defp local_time, do: NaiveDateTime.to_time(NaiveDateTime.local_now())
  defp local_time_iso, do: Time.to_iso8601(local_time())

  describe "add/0" do
    test "returns a random time" do
      assert FakeTime.add(0..0) == local_time()
    end

    test "returns a random time with unit option" do
      for unit <- [:hour, :minute, :second] do
        assert FakeTime.add(0..0, unit: unit) == local_time()
      end
    end

    test "returns a random time in ISO 8601" do
      assert FakeTime.add(0..0, format: :iso8601) == local_time_iso()
    end
  end

  describe "between/3" do
    test "returns a random time between start and finish times" do
      now = local_time()

      assert FakeTime.between(now, now) == now
    end

    test "returns a random time in ISO 8601" do
      now = local_time()

      assert FakeTime.between(now, now, format: :iso8601) == Time.to_iso8601(now)
    end
  end

  describe "time_zone/0" do
    test "returns a random time zone" do
      time_zone =
        :default
        |> Cache.fetch!(NeoFaker.Time, "time_zone.exs")
        |> Map.get("time_zone")

      assert FakeTime.time_zone() in time_zone
    end
  end
end
