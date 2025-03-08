defmodule NeoFaker.LoremTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Lorem

  describe "paragraph/1" do
    test "returns a random paragraph" do
      assert is_binary(Lorem.paragraph())
    end
  end

  describe "sentence/1" do
    test "returns a random sentence" do
      assert is_binary(Lorem.sentence())
    end
  end

  describe "words/1" do
    test "returns a list of random words" do
      assert is_binary(Lorem.word())
    end
  end
end
