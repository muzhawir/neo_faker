defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Person

  @module Person

  defp valid_name?(name), do: is_binary(name) and String.valid?(name) and name != ""

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

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

  describe "default-argument entry points" do
    test "prefix/0, suffix/0, gender/0 and full_name_with_title/0 work with no arguments" do
      assert valid_name?(Person.prefix())
      assert valid_name?(Person.suffix())
      assert valid_name?(Person.gender())
      assert valid_name?(Person.full_name_with_title())
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

  describe "gender/1" do
    test "returns a binary gender from the default locale word list" do
      word_list = fetch_key(:default, "gender.exs", "binary")

      assert Person.gender(locale: :default) in word_list
    end

    test "returns a binary gender from the id_id locale word list" do
      word_list = fetch_key(:id_id, "gender.exs", "binary")

      assert Person.gender(locale: :id_id) in word_list
    end

    test "defaults to the binary format" do
      word_list = fetch_key(:default, "gender.exs", "binary")

      assert Person.gender(locale: :default) in word_list
    end

    test "returns a short binary gender with format: :short_binary" do
      result = Person.gender(format: :short_binary, locale: :default)

      assert String.match?(result, ~r/^[A-Z]$/)
    end

    test "returns a non-binary gender from the default locale word list with format: :non_binary" do
      word_list = fetch_key(:default, "gender.exs", "non_binary")

      assert Person.gender(format: :non_binary, locale: :default) in word_list
    end

    test "returns a non-binary gender from the id_id locale word list with format: :non_binary" do
      word_list = fetch_key(:id_id, "gender.exs", "non_binary")

      assert Person.gender(format: :non_binary, locale: :id_id) in word_list
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

  describe "name option validation" do
    test "first_name/1 raises NimbleOptions.ValidationError for an unknown :sex" do
      assert_raise NimbleOptions.ValidationError, fn -> Person.first_name(sex: :other) end
    end

    test "first_name/1 draws from the right list for every sex" do
      for sex <- [:unisex, :male, :female] do
        assert valid_name?(Person.first_name(sex: sex))
      end
    end

    test "middle_name/1 and last_name/1 accept every sex" do
      for sex <- [:unisex, :male, :female] do
        assert valid_name?(Person.middle_name(sex: sex))
        assert valid_name?(Person.last_name(sex: sex))
      end
    end
  end

  describe "full_name/1" do
    test "returns three space-separated tokens by default" do
      assert Person.full_name() |> String.split() |> length() == 3
    end

    test "omits the middle name when middle_name: false" do
      assert [middle_name: false] |> Person.full_name() |> String.split() |> length() == 2
    end

    test "accepts every sex, including per-call :unisex resolution" do
      for sex <- [:unisex, :male, :female], _ <- 1..20 do
        assert valid_name?(Person.full_name(sex: sex))
      end
    end

    test "honours a per-call locale" do
      assert valid_name?(Person.full_name(locale: :id_id, middle_name: false))
    end

    test "raises NimbleOptions.ValidationError for a non-boolean :middle_name" do
      assert_raise NimbleOptions.ValidationError, fn -> Person.full_name(middle_name: :yes) end
    end
  end

  describe "age/2 bounds and errors" do
    test "stays within a custom window" do
      assert Person.age(7, 44) in 7..44
    end

    test "raises ArgumentError for a negative bound" do
      assert_raise ArgumentError, ~r/min must be non-negative/, fn -> Person.age(-1, 10) end
      assert_raise ArgumentError, ~r/max must be non-negative/, fn -> Person.age(0, -1) end
    end

    test "raises ArgumentError when min exceeds max" do
      assert_raise ArgumentError, ~r/min must be less than or equal to max/, fn ->
        Person.age(50, 10)
      end
    end

    test "raises ArgumentError for a non-integer bound" do
      assert_raise ArgumentError, ~r/min must be an integer/, fn ->
        Person.age(opaque(:a), 10)
      end

      assert_raise ArgumentError, ~r/max must be an integer/, fn ->
        Person.age(0, opaque(:b))
      end
    end
  end

  describe "gender/1 formats and errors" do
    test "returns a short binary code for every locale" do
      assert Person.gender(format: :short_binary, locale: :id_id) =~ ~r/^[A-Z]$/
    end

    test "raises NimbleOptions.ValidationError for an unknown format" do
      assert_raise NimbleOptions.ValidationError, fn -> Person.gender(format: :fluid) end
    end
  end

  describe "FullNameGenerator.name/3" do
    alias NeoFaker.Person.FullNameGenerator

    test "resolves :unisex to a concrete sex before delegating" do
      for _ <- 1..20 do
        assert valid_name?(FullNameGenerator.name(:unisex, nil, true))
      end
    end

    test "builds names with and without a middle name for a fixed sex" do
      assert :male |> FullNameGenerator.name(nil, true) |> String.split() |> length() == 3
      assert :female |> FullNameGenerator.name(nil, false) |> String.split() |> length() == 2
    end
  end

  describe "Validator.validate_age_range!/2" do
    alias NeoFaker.Person.Validator

    test "returns :ok for a valid window" do
      assert Validator.validate_age_range!(0, 120) == :ok
    end

    test "raises ArgumentError for each invalid shape" do
      assert_raise ArgumentError, ~r/min must be non-negative/, fn ->
        Validator.validate_age_range!(-1, 10)
      end

      assert_raise ArgumentError, ~r/max must be non-negative/, fn ->
        Validator.validate_age_range!(0, -1)
      end

      assert_raise ArgumentError, ~r/min must be less than or equal to max/, fn ->
        Validator.validate_age_range!(10, 5)
      end

      assert_raise ArgumentError, ~r/min must be an integer/, fn ->
        Validator.validate_age_range!(opaque(:a), 5)
      end

      assert_raise ArgumentError, ~r/max must be an integer/, fn ->
        Validator.validate_age_range!(5, opaque(:b))
      end
    end
  end
end
