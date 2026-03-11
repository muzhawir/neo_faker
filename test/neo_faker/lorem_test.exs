defmodule NeoFaker.LoremTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Lorem

  describe "paragraph/1" do
    test "returns a random paragraph" do
      assert is_binary(Lorem.paragraph())
    end

    test "returns a random paragraph with type option" do
      assert is_binary(Lorem.paragraph(type: :meditations))
    end
  end

  describe "sentence/1" do
    test "returns a random sentence" do
      assert is_binary(Lorem.sentence())
    end

    test "returns a random sentence with type option" do
      assert is_binary(Lorem.sentence(type: :meditations))
    end
  end

  describe "word/1" do
    test "returns a random word" do
      assert is_binary(Lorem.word())
    end

    test "returns a random word with type option" do
      assert is_binary(Lorem.word(type: :meditations))
    end
  end
end
