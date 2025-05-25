defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate

  defp today, do: NaiveDateTime.to_date(NaiveDateTime.local_now())
  defp today_iso, do: Date.to_iso8601(today())

  describe "add/2" do
    test "returns a random date in Date format" do
      assert FakeDate.add(0..0) == today()
    end

    test "returns a random date in ISO 8601 format" do
      assert FakeDate.add(0..0, format: :iso8601) == today_iso()
    end
  end

  describe "between/3" do
    test "returns a random date in Date format" do
      assert FakeDate.between(today(), today()) == today()
    end

    test "returns a random date in ISO 8601 format" do
      assert FakeDate.between(today(), today(), format: :iso8601) == today_iso()
    end
  end

  describe "birthday/2" do
    test "returns a random birthday in Date format" do
      assert FakeDate.birthday(0, 0) == today()
    end

    test "returns a random birthday in ISO 8601 format" do
      assert FakeDate.birthday(0, 0, format: :iso8601) == today_iso()
    end
  end
end
