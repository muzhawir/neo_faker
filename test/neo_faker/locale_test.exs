defmodule NeoFaker.LocaleTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Locale

  describe "fetch/0" do
    test "returns current locale as an atom" do
      assert {:ok, locale} = Locale.fetch()
      assert is_atom(locale)
    end
  end

  describe "set/1" do
    test "sets the current locale and returns :ok" do
      assert Locale.set(:id_id) == :ok
    end

    test "accepts :en_us and returns :ok" do
      assert Locale.set(:en_us) == :ok
    end

    test "accepts :default and returns :ok" do
      assert Locale.set(:default) == :ok
    end

    test "raises ArgumentError when locale is not an atom" do
      assert_raise ArgumentError, ~r/Locale must be an atom/, fn ->
        Locale.set("en_us")
      end
    end

    test "raises ArgumentError for an unsupported atom locale" do
      assert_raise ArgumentError, ~r/Unsupported locale :bogus/, fn ->
        Locale.set(:bogus)
      end
    end

    test "error message for unsupported locale dynamically includes supported locales" do
      error =
        assert_raise ArgumentError, fn ->
          Locale.set(:totally_unknown)
        end

      supported = Locale.supported()

      for locale <- supported do
        assert String.contains?(error.message, Atom.to_string(locale)),
               "expected error message to mention :#{locale}, got: #{error.message}"
      end

      assert String.contains?(error.message, "default"),
             "expected error message to mention :default, got: #{error.message}"
    end

    test "error message for unsupported locale references the documentation" do
      error =
        assert_raise ArgumentError, fn ->
          Locale.set(:not_a_real_locale)
        end

      assert String.contains?(error.message, "available locales documentation")
    end
  end

  describe "get/0" do
    test "returns the active locale as an atom" do
      Locale.set(:en_us)
      assert Locale.get() == :en_us
    end
  end

  describe "supported/0" do
    test "returns a sorted list of supported locale atoms" do
      supported = Locale.supported()

      assert is_list(supported)
      assert Enum.all?(supported, &is_atom/1)
      assert supported == Enum.sort(supported)
      assert :en_us in supported
      assert :id_id in supported
    end

    test "does not include :default" do
      refute :default in Locale.supported()
    end
  end

  describe "available?/1" do
    test "returns true for every supported locale" do
      assert Enum.all?(Locale.supported(), &Locale.available?/1)
    end

    test "returns false for an unsupported locale" do
      refute Locale.available?(:bogus)
    end
  end
end
