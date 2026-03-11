defmodule NeoFaker.DataTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data

  # Use a known-good module/file/key triple that is guaranteed to exist so that
  # valid-input tests exercise the full call path through fetch!/3 and
  # random_value/4 without hitting a missing-file error.
  @module NeoFaker.Text
  @valid_file "word.exs"
  @valid_key "words"

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
        Data.fetch!(:default, @module, :word)
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
      assert is_binary(Data.random_value(@module, @valid_file, @valid_key))
    end

    test "raises ArgumentError for a path-traversal filename" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "../../config/runtime.exs", "key")
      end
    end

    test "raises ArgumentError for a filename with a leading directory component" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "subdir/word.exs", @valid_key)
      end
    end

    test "raises ArgumentError for a filename with a non-.exs extension" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "word.json", @valid_key)
      end
    end

    test "raises ArgumentError for an empty filename" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "", @valid_key)
      end
    end

    test "raises ArgumentError when filename is not a string" do
      assert_raise ArgumentError, ~r/data file name must be a string/, fn ->
        Data.random_value(@module, :word_exs, @valid_key)
      end
    end

    test "raises ArgumentError for an absolute path" do
      assert_raise ArgumentError, ~r/invalid data file name/, fn ->
        Data.random_value(@module, "/etc/passwd.exs", @valid_key)
      end
    end
  end
end
