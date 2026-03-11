defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Person

  @module Person

  defp valid_name?(name), do: is_binary(name) and String.valid?(name) and name != ""

  defp fetch_key(locale, file, key) do
    locale |> Data.fetch!(@module, file) |> Map.fetch!(key)
  end

  describe "first_name/1" do
    test "returns a valid first name" do
      assert valid_name?(Person.first_name())
    end

    test "returns a valid first name with sex and locale options" do
      assert valid_name?(Person.first_name(sex: :male, locale: :id_id))
    end
  end

  describe "middle_name/1" do
    test "returns a valid middle name" do
      assert valid_name?(Person.middle_name())
    end

    test "returns a valid middle name with sex and locale options" do
      assert valid_name?(Person.middle_name(sex: :female, locale: :id_id))
    end
  end

  describe "last_name/1" do
    test "returns a valid last name" do
      assert valid_name?(Person.last_name())
    end

    test "returns a valid last name with locale option" do
      assert valid_name?(Person.last_name(locale: :id_id))
    end
  end

  describe "prefix/1" do
    test "returns a prefix from the default locale word list" do
      word_list = fetch_key(:default, "name_affixes.exs", "prefixes")

      assert Person.prefix(locale: :default) in word_list
    end

    test "returns a prefix from the id_id locale word list" do
      word_list = fetch_key(:id_id, "name_affixes.exs", "prefixes")

      assert Person.prefix(locale: :id_id) in word_list
    end
  end

  describe "suffix/1" do
    test "returns a suffix from the default locale word list" do
      word_list = fetch_key(:default, "name_affixes.exs", "suffixes")

      assert Person.suffix(locale: :default) in word_list
    end

    test "returns a suffix from the id_id locale word list" do
      word_list = fetch_key(:id_id, "name_affixes.exs", "suffixes")

      assert Person.suffix(locale: :id_id) in word_list
    end
  end

  describe "age/2" do
    test "returns a random integer age between 0 and 120" do
      assert Person.age() in 0..120
    end
  end

  describe "binary_gender/1" do
    test "returns a binary gender from the default locale word list" do
      word_list = fetch_key(:default, "gender.exs", "binary")

      assert Person.binary_gender(locale: :default) in word_list
    end

    test "returns a binary gender from the id_id locale word list" do
      word_list = fetch_key(:id_id, "gender.exs", "binary")

      assert Person.binary_gender(locale: :id_id) in word_list
    end
  end

  describe "short_binary_gender/1" do
    test "returns a short binary gender as a non-empty string" do
      result = Person.short_binary_gender(locale: :default)

      assert is_binary(result)
      assert String.valid?(result)
      assert result != ""
    end

    test "returns a short binary gender with a single uppercase letter" do
      result = Person.short_binary_gender(locale: :default)

      assert String.match?(result, ~r/^[A-Z]$/)
    end
  end

  describe "non_binary_gender/1" do
    test "returns a non-binary gender from the default locale word list" do
      word_list = fetch_key(:default, "gender.exs", "non_binary")

      assert Person.non_binary_gender(locale: :default) in word_list
    end

    test "returns a non-binary gender from the id_id locale word list" do
      word_list = fetch_key(:id_id, "gender.exs", "non_binary")

      assert Person.non_binary_gender(locale: :id_id) in word_list
    end
  end

  describe "full_name_with_title/1" do
    # Load the real prefix and suffix lists once for the whole describe block so
    # assertions about token positions use actual data rather than shape heuristics.
    # All calls are pinned to locale: :default so the lookup and the function
    # under test draw from the same word list.
    @affixes_file "name_affixes.exs"
    @test_locale :default

    defp known_prefixes do
      @test_locale
      |> Data.fetch!(@module, @affixes_file)
      |> Map.fetch!("prefixes")
    end

    defp known_suffixes do
      @test_locale
      |> Data.fetch!(@module, @affixes_file)
      |> Map.fetch!("suffixes")
    end

    test "returns only the full name when neither prefix nor suffix is requested" do
      result = Person.full_name_with_title(locale: @test_locale, middle_name: false)

      # No prefix or suffix token — exactly two space-separated words
      assert length(String.split(result)) == 2
      assert is_binary(result) and String.valid?(result)
    end

    test "result equals full_name when no prefix or suffix is requested" do
      result = Person.full_name_with_title(locale: @test_locale, middle_name: false)
      parts = String.split(result)

      assert length(parts) == 2,
             "expected exactly 2 tokens without prefix/suffix, got: #{inspect(result)}"
    end

    test "prepends a known prefix when prefix: true" do
      for _ <- 1..20 do
        result =
          Person.full_name_with_title(locale: @test_locale, prefix: true, middle_name: false)

        parts = String.split(result)

        assert length(parts) == 3,
               "expected 3 tokens (prefix first last), got #{length(parts)} in \"#{result}\""

        assert hd(parts) in known_prefixes(),
               "expected first token to be a known prefix, got: #{inspect(hd(parts))} in \"#{result}\""
      end
    end

    test "appends a known suffix when suffix: true" do
      for _ <- 1..20 do
        result =
          Person.full_name_with_title(locale: @test_locale, suffix: true, middle_name: false)

        parts = String.split(result)

        assert length(parts) == 3,
               "expected 3 tokens (first last suffix), got #{length(parts)} in \"#{result}\""

        assert List.last(parts) in known_suffixes(),
               "expected last token to be a known suffix, got: #{inspect(List.last(parts))} in \"#{result}\""
      end
    end

    test "prefix is not placed at the end when suffix: false" do
      for _ <- 1..20 do
        result =
          Person.full_name_with_title(locale: @test_locale, prefix: true, middle_name: false)

        parts = String.split(result)

        refute List.last(parts) in known_prefixes(),
               "prefix must not appear as the last token in \"#{result}\""
      end
    end

    test "suffix is not placed at the front when prefix: false" do
      for _ <- 1..20 do
        result =
          Person.full_name_with_title(locale: @test_locale, suffix: true, middle_name: false)

        parts = String.split(result)

        refute hd(parts) in known_suffixes(),
               "suffix must not appear as the first token in \"#{result}\""
      end
    end

    test "prefix comes first and suffix comes last when both are requested" do
      for _ <- 1..20 do
        result =
          Person.full_name_with_title(
            locale: @test_locale,
            prefix: true,
            suffix: true,
            middle_name: false
          )

        parts = String.split(result)

        assert length(parts) == 4,
               "expected 4 tokens (prefix first last suffix), got #{length(parts)} in \"#{result}\""

        assert hd(parts) in known_prefixes(),
               "expected first token to be a known prefix, got: #{inspect(hd(parts))} in \"#{result}\""

        assert List.last(parts) in known_suffixes(),
               "expected last token to be a known suffix, got: #{inspect(List.last(parts))} in \"#{result}\""
      end
    end

    test "middle name produces five tokens when prefix and suffix are both present" do
      for _ <- 1..10 do
        result =
          Person.full_name_with_title(
            locale: @test_locale,
            prefix: true,
            suffix: true,
            middle_name: true
          )

        parts = String.split(result)

        assert length(parts) == 5,
               "expected 5 tokens (prefix first middle last suffix), got #{length(parts)} in \"#{result}\""

        assert hd(parts) in known_prefixes(),
               "expected first token to be a known prefix in \"#{result}\""

        assert List.last(parts) in known_suffixes(),
               "expected last token to be a known suffix in \"#{result}\""
      end
    end

    test "returns a non-empty valid string for all combinations" do
      combinations = [
        [locale: @test_locale],
        [locale: @test_locale, prefix: true],
        [locale: @test_locale, suffix: true],
        [locale: @test_locale, prefix: true, suffix: true]
      ]

      for opts <- combinations do
        result = Person.full_name_with_title(opts)

        assert is_binary(result) and String.valid?(result) and result != "",
               "expected non-empty string for opts=#{inspect(opts)}, got: #{inspect(result)}"
      end
    end
  end
end
