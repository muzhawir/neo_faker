defmodule NeoFaker.TextTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helper.Locale
  alias NeoFaker.Text

  @alphanumeric_regexp ~r/[a-zA-Z0-9]/

  defp emojis do
    NeoFaker.Text
    |> Locale.load_persistent_term("emoji.exs")
    |> Map.values()
    |> List.flatten()
  end

  describe "character/1" do
    test "returns a single random character" do
      assert Text.character() =~ @alphanumeric_regexp
    end

    test "returns a single random character with option" do
      options = [:alphabet_lower, :alphabet_upper, :alphabet, :digit]

      for option <- options do
        assert Text.character(type: option) =~ @alphanumeric_regexp
      end
    end
  end

  describe "characters/1" do
    test "returns a strings of random characters" do
      assert Text.characters() =~ @alphanumeric_regexp
    end

    test "returns a strings of random characters with option" do
      options = [:alphabet_lower, :alphabet_upper, :alphabet, :digit]

      for option <- options do
        assert Text.characters(11, type: option) =~ @alphanumeric_regexp
      end
    end
  end

  describe "emoji/1" do
    test "returns a random emoji" do
      assert Text.emoji() in emojis()
    end

    test "returns a random emoji with option" do
      options = [
        :activities,
        :food_and_drink,
        :objects,
        :people_and_body,
        :animals_and_nature,
        :smileys_and_emotion,
        :symbols,
        :travel_and_places
      ]

      for option <- options do
        assert Text.emoji(category: option) in emojis()
      end
    end
  end
end
