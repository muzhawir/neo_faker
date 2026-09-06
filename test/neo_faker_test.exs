defmodule NeoFakerTest do
  use ExUnit.Case, async: true

  describe "start/0" do
    test "starts the application and returns :ok" do
      assert NeoFaker.start() == :ok
    end
  end
end
