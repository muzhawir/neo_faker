defmodule NeoFaker.LoremTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Lorem

  describe "paragraph/1" do
    test "returns a random paragraph" do
      assert is_binary(Lorem.paragraph())
    end

    test "returns a random paragraph with type option" do
      assert is_binary(Lorem.paragraph(text: :meditations))
    end
  end

  describe "sentence/1" do
    test "returns a random sentence" do
      assert is_binary(Lorem.sentence())
    end

    test "returns a random sentence with type option" do
      assert is_binary(Lorem.sentence(text: :meditations))
    end

    test "never returns a blank sentence, across many draws" do
      for text <- [:lorem, :meditations], _ <- 1..200 do
        sentence = Lorem.sentence(text: text)

        assert sentence =~ ~r/\S/, "blank sentence for text: #{inspect(text)}"
      end
    end
  end

  describe "word/1" do
    test "returns a random word" do
      assert is_binary(Lorem.word())
    end

    test "returns a non-empty word for each text source, across many draws" do
      # Regression: a source string with a trailing space after its last
      # sentence produced an empty "sentence", and Lorem.word/1 then called
      # Enum.random/1 on a wordless list and crashed.
      for text <- [:lorem, :meditations], _ <- 1..200 do
        word = Lorem.word(text: text)

        assert is_binary(word)
        assert word =~ ~r/\S/, "Lorem.word(text: #{inspect(text)}) returned #{inspect(word)}"
      end
    end
  end
end
