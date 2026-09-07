defmodule NeoFaker.LoremTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Lorem
  alias NeoFaker.Lorem.Generator

  describe "paragraph/1" do
    test "returns a random paragraph from each text source" do
      for text <- [:lorem, :meditations] do
        assert is_binary(Lorem.paragraph(text: text))
      end
    end

    test "collapses mid-paragraph line wraps to single spaces" do
      refute Lorem.paragraph() =~ "\n"
    end

    test "raises NimbleOptions.ValidationError for an unknown text source" do
      assert_raise NimbleOptions.ValidationError, fn -> Lorem.paragraph(text: :odyssey) end
    end
  end

  describe "sentence/1" do
    test "returns a random sentence with no options" do
      assert is_binary(Lorem.sentence())
    end

    test "returns a random sentence for each text source" do
      for text <- [:lorem, :meditations] do
        assert is_binary(Lorem.sentence(text: text))
      end
    end

    test "never returns a blank sentence, across many draws" do
      for text <- [:lorem, :meditations], _ <- 1..200 do
        assert Lorem.sentence(text: text) =~ ~r/\S/, "blank sentence for text: #{inspect(text)}"
      end
    end
  end

  describe "word/1" do
    test "returns a random word with no options" do
      assert is_binary(Lorem.word())
    end

    test "returns a lowercase, punctuation-free word for each text source" do
      for text <- [:lorem, :meditations], _ <- 1..200 do
        word = Lorem.word(text: text)

        assert is_binary(word)
        assert word =~ ~r/\S/
        assert word == String.downcase(word)
      end
    end
  end

  describe "paragraphs/2" do
    test "returns a list of the requested size by default" do
      assert length(Lorem.paragraphs(4)) == 4
      assert length(Lorem.paragraphs()) == 3
    end

    test "every entry is a non-blank string" do
      assert Enum.all?(Lorem.paragraphs(3), &(is_binary(&1) and &1 =~ ~r/\S/))
    end

    test "passes the text source through" do
      assert length(Lorem.paragraphs(2, text: :meditations)) == 2
    end

    test "raises NimbleOptions.ValidationError for the removed :join option" do
      assert_raise NimbleOptions.ValidationError, fn -> Lorem.paragraphs(2, join: true) end
    end

    test "raises FunctionClauseError for a non-positive count" do
      assert_raise FunctionClauseError, fn -> Lorem.paragraphs(0) end
    end
  end

  describe "sentences/2" do
    test "returns a list of the requested size by default" do
      assert length(Lorem.sentences(6)) == 6
      assert length(Lorem.sentences()) == 5
    end

    test "every entry is a non-blank string" do
      assert Enum.all?(Lorem.sentences(4), &(is_binary(&1) and &1 =~ ~r/\S/))
    end

    test "raises FunctionClauseError for a non-positive count" do
      assert_raise FunctionClauseError, fn -> Lorem.sentences(-1) end
    end
  end

  describe "words/2" do
    test "returns a list of the requested size by default" do
      assert length(Lorem.words(12)) == 12
      assert length(Lorem.words()) == 10
    end

    test "passes text and locale through" do
      assert length(Lorem.words(3, text: :meditations, locale: :default)) == 3
    end

    test "raises FunctionClauseError for a non-positive count" do
      assert_raise FunctionClauseError, fn -> Lorem.words(0) end
    end
  end

  describe "Generator" do
    test "text_file/1 maps each source to its data file" do
      assert Generator.text_file(:lorem) == "lorem_ipsum.exs"
      assert Generator.text_file(:meditations) == "meditations.exs"
    end

    test "normalize/1 collapses single newlines but keeps paragraph breaks" do
      assert Generator.normalize("a\nb\n\nc") == "a b\n\nc"
    end

    test "split_sentences/1 keeps the delimiter and drops blank fragments" do
      assert Generator.split_sentences("One. Two! ") == ["One.", "Two!"]
    end

    test "remove_punctuation/1 strips punctuation" do
      assert Generator.remove_punctuation("a, b. c!") == "a b c"
    end

    test "split_words/1 splits on whitespace" do
      assert Generator.split_words("a b  c") == ["a", "b", "c"]
    end

    test "extract_paragraph/1 returns one non-blank paragraph" do
      assert Generator.extract_paragraph("first\n\nsecond") in ["first", "second"]
    end
  end
end
