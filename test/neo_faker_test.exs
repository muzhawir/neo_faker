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
  end

  describe "set_locale/1" do
    test "sets the current locale and returns :ok" do
      assert NeoFaker.set_locale(:id_id) == :ok
    end

    test "raises ArgumentError when locale is not an atom" do
      assert_raise ArgumentError, fn ->
        NeoFaker.set_locale("en_us")
      end
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
