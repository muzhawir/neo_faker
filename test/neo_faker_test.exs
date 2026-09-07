defmodule NeoFakerTest do
  use ExUnit.Case, async: true

  describe "start/0" do
    test "starts the application and returns :ok" do
      assert NeoFaker.start() == :ok
    end
  end

  describe "seed/1" do
    test "accepts an integer seed and returns :ok" do
      assert NeoFaker.seed(12_345) == :ok
    end

    test "accepts a three-element tuple seed and returns :ok" do
      assert NeoFaker.seed({1, 2, 3}) == :ok
    end

    test "makes subsequent random draws reproducible" do
      NeoFaker.seed(42)
      first = for _ <- 1..20, do: NeoFaker.Number.between(1, 1_000_000)

      NeoFaker.seed(42)
      second = for _ <- 1..20, do: NeoFaker.Number.between(1, 1_000_000)

      assert first == second
    end
  end
end
