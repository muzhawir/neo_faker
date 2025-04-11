defmodule NeoFaker.TimeTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Time, as: FakeTime

  describe "add/0" do
    test "returns a random time" do
      assert FakeTime.add(0..0) == NaiveDateTime.to_time(NaiveDateTime.local_now())
    end

    test "returns a random time with unit option" do
      option = [:hour, :minute, :second]

      for unit <- option do
        assert FakeTime.add(0..0, unit: unit) == NaiveDateTime.to_time(NaiveDateTime.local_now())
      end
    end

    test "returns a random time in ISO 8601" do
      time_in_iso8601 =
        NaiveDateTime.local_now()
        |> NaiveDateTime.to_time()
        |> Time.to_iso8601()

      assert FakeTime.add(0..0, format: :iso8601) == time_in_iso8601
    end
  end
end
