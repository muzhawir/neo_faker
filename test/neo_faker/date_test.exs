defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate

  describe "add/2" do
    test "returns a random date in Date format" do
      assert FakeDate.add(0..0) == NaiveDateTime.to_date(NaiveDateTime.local_now())
    end

    test "returns a random date in ISO 8601 format" do
      assert FakeDate.add(0..0, format: :iso8601) ==
               NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.to_iso8601()
    end
  end

  describe "between/3" do
    test "returns a random date in Date format" do
      today = NaiveDateTime.to_date(NaiveDateTime.local_now())

      assert FakeDate.between(today, today) == today
    end

    test "returns a random date in ISO 8601 format" do
      today = NaiveDateTime.to_date(NaiveDateTime.local_now())

      assert FakeDate.between(today, today, format: :iso8601) == Date.to_iso8601(today)
    end
  end

  describe "birthday/2" do
    test "returns a random birthday in Date format" do
      assert FakeDate.birthday(0, 0) == NaiveDateTime.to_date(NaiveDateTime.local_now())
    end

    test "returns a random birthday in ISO 8601 format" do
      birth_date = NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.to_iso8601()

      assert FakeDate.birthday(0, 0, format: :iso8601) == birth_date
    end
  end
end
