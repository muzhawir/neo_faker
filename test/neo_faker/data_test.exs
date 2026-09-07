defmodule NeoFaker.DataTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data

  # Use a known-good module/file/key triple that is guaranteed to exist so that
  # valid-input tests exercise the full call path through fetch!/3 and
  # random_value/4 without hitting a missing-file error.
  @module NeoFaker.Text
  @valid_file "word.exs"
  @valid_key "words"

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

  # ---------------------------------------------------------------------------
  # fetch!/3 – file name validation
  # ---------------------------------------------------------------------------

  describe "fetch!/3 file name validation" do
    test "accepts a valid bare filename with .exs extension" do
      assert is_map(Data.fetch!(:default, @module, @valid_file))
    end

    test "raises ArgumentError for a path-traversal filename" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.fetch!(:default, @module, "../../config/runtime.exs")
      end
    end

    test "raises ArgumentError for a filename with a leading directory component" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.fetch!(:default, @module, "subdir/word.exs")
      end
    end

    test "raises ArgumentError for a filename with no extension" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.fetch!(:default, @module, "word")
      end
    end

    test "raises ArgumentError for a filename with a non-.exs extension" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.fetch!(:default, @module, "word.ex")
      end
    end

    test "raises ArgumentError for an empty filename" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.fetch!(:default, @module, "")
      end
    end

    test "raises ArgumentError when filename is not a string" do
      assert_raise ArgumentError, ~r/data file name must be a string/, fn ->
        Data.fetch!(:default, @module, opaque(:word))
      end
    end

    test "raises ArgumentError for an absolute path" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.fetch!(:default, @module, "/etc/passwd.exs")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # random_value/4 – file name validation
  # ---------------------------------------------------------------------------

  describe "random_value/4 file name validation" do
    test "accepts a valid bare filename with .exs extension" do
      assert is_binary(Data.random_value(@module, @valid_file, @valid_key, locale: :default))
    end

    test "raises ArgumentError for a path-traversal filename" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "../../config/runtime.exs", "key", locale: :default)
      end
    end

    test "raises ArgumentError for a filename with a leading directory component" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "subdir/word.exs", @valid_key, locale: :default)
      end
    end

    test "raises ArgumentError for a filename with a non-.exs extension" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "word.json", @valid_key, locale: :default)
      end
    end

    test "raises ArgumentError for a filename with no extension" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "word", @valid_key, locale: :default)
      end
    end

    test "raises ArgumentError for an empty filename" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "", @valid_key, locale: :default)
      end
    end

    test "raises ArgumentError when filename is not a string" do
      assert_raise ArgumentError, ~r/data file name must be a string/, fn ->
        Data.random_value(@module, opaque(:word_exs), @valid_key, locale: :default)
      end
    end

    test "raises ArgumentError for an absolute path" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "/etc/passwd.exs", @valid_key, locale: :default)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Locale resolution and loading
  # ---------------------------------------------------------------------------

  describe "locale resolution" do
    test "loads locale-specific data when the file exists for that locale" do
      cities = :id_id |> Data.fetch!(NeoFaker.Address, "city.exs") |> Map.fetch!("city")

      assert NeoFaker.Address.city(locale: :id_id) in cities
    end

    test "silently falls back to :default when a locale has no copy of the file" do
      default_words = :default |> Data.fetch!(NeoFaker.Text, "word.exs") |> Map.fetch!("words")

      # :id_id ships no text/word.exs, so this must resolve to the default set.
      assert :id_id |> Data.fetch!(NeoFaker.Text, "word.exs") |> Map.fetch!("words") ==
               default_words
    end

    test "random_value/4 with no explicit locale uses the active locale" do
      NeoFaker.Locale.set(:default)
      words = :default |> Data.fetch!(@module, @valid_file) |> Map.fetch!(@valid_key)

      assert Data.random_value(@module, @valid_file, @valid_key) in words
    end

    test "repeated reads return the cached, de-duplicated map" do
      first = Data.fetch!(:default, @module, @valid_file)
      second = Data.fetch!(:default, @module, @valid_file)

      assert first == second
      assert Enum.uniq(first[@valid_key]) == first[@valid_key]
    end
  end
end
