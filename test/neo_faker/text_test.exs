defmodule NeoFaker.TextTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Text

  @alphanumeric_regexp ~r/[a-zA-Z0-9]/

  defp emojis do
    :default
    |> Data.fetch!(Text, "emoji.exs")
    |> Map.values()
    |> List.flatten()
  end

  describe "character/1" do
    test "returns a single random alphanumeric character" do
      assert Text.character() =~ @alphanumeric_regexp
    end

    test "returns a single random character for each supported type" do
      for type <- [:alphabet_lower, :alphabet_upper, :alphabet, :digit] do
        assert Text.character(type: type) =~ @alphanumeric_regexp
      end
    end
  end

  describe "characters/2" do
    test "returns a string of random alphanumeric characters" do
      assert Text.characters() =~ @alphanumeric_regexp
    end

    test "returns a string of random characters for each supported type" do
      for type <- [:alphabet_lower, :alphabet_upper, :alphabet, :digit] do
        assert Text.characters(11, type: type) =~ @alphanumeric_regexp
      end
    end

    test "returns a string with the specified length" do
      result = Text.characters(8)

      assert is_binary(result)
      assert String.length(result) == 8
    end
  end

  describe "emoji/1" do
    test "returns a random emoji from the default list" do
      assert Text.emoji() in emojis()
    end

    test "returns a random emoji for each supported category" do
      for category <- [
            :activities,
            :food_and_drink,
            :objects,
            :people_and_body,
            :animals_and_nature,
            :smileys_and_emotion,
            :symbols,
            :travel_and_places
          ] do
        assert Text.emoji(category: category) in emojis()
      end
    end
  end

  describe "word/0" do
    test "returns a random alphanumeric word" do
      assert Text.word() =~ @alphanumeric_regexp
    end

    test "every entry in the word list is a single whitespace-free token" do
      # NeoFaker.Internet builds usernames, domain labels, and slugs by joining
      # Text.word/0 results with a separator and, in some tests, counting the
      # parts. A multi-word entry ("ice cream") would smuggle a space into those
      # tokens and make those tests flaky, so the source list must stay to
      # single words only.
      words =
        :default
        |> Data.fetch!(Text, "word.exs")
        |> Map.fetch!("words")

      multi_word = Enum.filter(words, &(&1 =~ ~r/\s/))

      assert multi_word == [],
             "word.exs must contain single words only, found: #{inspect(multi_word)}"
    end
  end
end
