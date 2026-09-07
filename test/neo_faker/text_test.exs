defmodule NeoFaker.TextTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Text
  alias NeoFaker.Text.Generator

  @alphanumeric_regexp ~r/^[a-zA-Z0-9]$/
  @categories [
    :activities,
    :animals_and_nature,
    :food_and_drink,
    :objects,
    :people_and_body,
    :smileys_and_emotion,
    :symbols,
    :travel_and_places
  ]

  defp emojis do
    :default |> Data.fetch!(Text, "emoji.exs") |> Map.values() |> List.flatten()
  end

  defp emojis(category) do
    :default |> Data.fetch!(Text, "emoji.exs") |> Map.fetch!(Atom.to_string(category))
  end

  describe "character/1" do
    test "returns a single alphanumeric character by default" do
      assert String.match?(Text.character(), @alphanumeric_regexp)
    end

    test "returns a character from the right pool for each type" do
      assert String.match?(Text.character(type: :alphabet_lower), ~r/^[a-z]$/)
      assert String.match?(Text.character(type: :alphabet_upper), ~r/^[A-Z]$/)
      assert String.match?(Text.character(type: :alphabet), ~r/^[a-zA-Z]$/)
      assert String.match?(Text.character(type: :digit), ~r/^[0-9]$/)
    end

    test "raises NimbleOptions.ValidationError for an unknown type" do
      assert_raise NimbleOptions.ValidationError, fn -> Text.character(type: :symbol) end
    end
  end

  describe "characters/2" do
    test "returns a string of the default length" do
      assert String.length(Text.characters()) == 11
    end

    test "returns a string of the requested length for each type" do
      for type <- [nil, :alphabet_lower, :alphabet_upper, :alphabet, :digit] do
        opts = if type, do: [type: type], else: []
        assert String.length(Text.characters(8, opts)) == 8
      end
    end

    test "raises ArgumentError for a non-positive length" do
      assert_raise ArgumentError, ~r/number must be a positive integer/, fn ->
        Text.characters(0)
      end
    end

    test "raises ArgumentError for a non-integer length" do
      assert_raise ArgumentError, ~r/number must be a positive integer/, fn ->
        Text.characters(:many)
      end
    end
  end

  describe "emoji/1" do
    test "returns an emoji from the combined list by default" do
      assert Text.emoji() in emojis()
    end

    test "returns an emoji from the requested category" do
      for category <- @categories do
        assert Text.emoji(category: category) in emojis(category)
      end
    end

    test "raises NimbleOptions.ValidationError for an unknown category" do
      assert_raise NimbleOptions.ValidationError, fn -> Text.emoji(category: :flags) end
    end
  end

  describe "word/0" do
    test "returns a word from the default word list" do
      words = :default |> Data.fetch!(Text, "word.exs") |> Map.fetch!("words")

      assert Text.word() in words
    end

    test "every entry in the word list is a single whitespace-free token" do
      words = :default |> Data.fetch!(Text, "word.exs") |> Map.fetch!("words")

      assert Enum.filter(words, &(&1 =~ ~r/\s/)) == []
    end
  end

  describe "words/1" do
    test "returns a list of the requested size" do
      assert length(Text.words(4)) == 4
      assert length(Text.words()) == 5
    end

    test "every entry is a single lowercase word from the list" do
      words = :default |> Data.fetch!(Text, "word.exs") |> Map.fetch!("words")

      assert Enum.all?(Text.words(10), &(&1 in words))
    end

    test "raises ArgumentError for a non-positive count" do
      assert_raise ArgumentError, ~r/count must be a positive integer/, fn -> Text.words(0) end
    end

    test "raises ArgumentError for a non-integer count" do
      assert_raise ArgumentError, ~r/count must be a positive integer/, fn ->
        Text.words(:five)
      end
    end
  end

  describe "Generator.character/1" do
    test "covers every branch" do
      assert String.match?(Generator.character(nil), @alphanumeric_regexp)
      assert String.match?(Generator.character(:alphabet_lower), ~r/^[a-z]$/)
      assert String.match?(Generator.character(:alphabet_upper), ~r/^[A-Z]$/)
      assert String.match?(Generator.character(:alphabet), ~r/^[a-zA-Z]$/)
      assert String.match?(Generator.character(:digit), ~r/^[0-9]$/)
    end
  end
end
