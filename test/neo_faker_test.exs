defmodule NeoFakerTest do
  use ExUnit.Case, async: true

  describe "start/0" do
    test "starts the application and returns :ok" do
      assert NeoFaker.start() == :ok
    end
  end

  describe "locale/0" do
    test "returns current locale as an atom" do
      assert {:ok, locale} = NeoFaker.locale()
      assert is_atom(locale)
    end

    test "raises ArgumentError when a bogus atom is stored directly in application env" do
      original = Application.get_env(:neo_faker, :locale)

      on_exit(fn ->
        case original do
          nil -> Application.delete_env(:neo_faker, :locale)
          value -> Application.put_env(:neo_faker, :locale, value)
        end
      end)

      Application.put_env(:neo_faker, :locale, :bogus_locale)

      assert_raise ArgumentError, ~r/Unsupported locale :bogus_locale/, fn ->
        NeoFaker.locale()
      end
    end
  end

  describe "set_locale/1" do
    test "sets the current locale and returns :ok" do
      assert NeoFaker.set_locale(:id_id) == :ok
    end

    test "accepts :en_us and returns :ok" do
      assert NeoFaker.set_locale(:en_us) == :ok
    end

    test "accepts :default and returns :ok" do
      assert NeoFaker.set_locale(:default) == :ok
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

    test "error message for unsupported locale dynamically includes supported locales" do
      error =
        assert_raise ArgumentError, fn ->
          NeoFaker.set_locale(:totally_unknown)
        end

      supported = NeoFaker.Data.supported_locales()

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
          NeoFaker.set_locale(:not_a_real_locale)
        end

      assert String.contains?(error.message, "available locales documentation")
    end
  end

  describe "get_locale/0" do
    test "returns the active locale as an atom" do
      NeoFaker.set_locale(:en_us)
      assert NeoFaker.get_locale() == :en_us
    end

    test "returns :default when no locale is set" do
      original = Application.get_env(:neo_faker, :locale)

      on_exit(fn ->
        case original do
          nil -> Application.delete_env(:neo_faker, :locale)
          value -> Application.put_env(:neo_faker, :locale, value)
        end
      end)

      Application.delete_env(:neo_faker, :locale)
      assert NeoFaker.get_locale() == :default
    end
  end
end
