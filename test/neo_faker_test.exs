defmodule NeoFakerTest do
  use ExUnit.Case, async: true

  describe "start/0" do
    test "starts the application and returns :ok" do
      assert NeoFaker.start() == :ok
    end
  end

  describe "locale/0 (deprecated, delegates to NeoFaker.Locale.fetch/0)" do
    test "returns current locale as an atom" do
      assert {:ok, locale} = NeoFaker.locale()
      assert is_atom(locale)
    end
  end

  describe "set_locale/1 (deprecated, delegates to NeoFaker.Locale.set/1)" do
    test "sets the current locale and returns :ok" do
      assert NeoFaker.set_locale(:id_id) == :ok
    end

    test "raises ArgumentError when locale is not an atom" do
      assert_raise ArgumentError, ~r/Locale must be an atom/, fn ->
        NeoFaker.set_locale("en_us")
      end
    end

    test "raises ArgumentError for an unsupported atom locale" do
      assert_raise ArgumentError, ~r/Unsupported locale :bogus/, fn ->
        NeoFaker.set_locale(:bogus)
      end
    end
  end

  describe "get_locale/0 (deprecated, delegates to NeoFaker.Locale.get/0)" do
    test "returns the active locale as an atom" do
      NeoFaker.set_locale(:en_us)
      assert NeoFaker.get_locale() == :en_us
    end
  end
end
