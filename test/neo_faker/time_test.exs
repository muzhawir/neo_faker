defmodule NeoFaker.TimeTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Time, as: FakeTime

  @local_now NaiveDateTime.to_time(NaiveDateTime.local_now())

  describe "add/0" do
    test "returns a random time" do
      assert FakeTime.add(0..0) == @local_now
    end

    test "returns a random time with unit option" do
      option = [:hour, :minute, :second]

      for unit <- option do
        assert FakeTime.add(0..0, unit: unit) == @local_now
      end
    end

    test "returns a random time in ISO 8601" do
      assert FakeTime.add(0..0, format: :iso8601) == Time.to_iso8601(@local_now)
    end
  end

  describe "between/3" do
    test "returns a random time between start and finish times" do
      assert FakeTime.between(@local_now, @local_now) == @local_now
    end

    test "returns a random time in ISO 8601" do
      assert FakeTime.between(@local_now, @local_now, format: :iso8601) ==
               Time.to_iso8601(@local_now)
    end
  end
end
