defmodule NeoFakerTest do
  use ExUnit.Case
  doctest NeoFaker

  test "greets the world" do
    assert NeoFaker.hello() == :world
  end
end
