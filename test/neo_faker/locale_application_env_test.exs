defmodule NeoFaker.LocaleApplicationEnvTest do
  use ExUnit.Case, async: false

  # `Application.put_env/3` and `Application.delete_env/2` mutate node-global state, not
  # process-scoped state, so these tests must not run concurrently with anything else that
  # reads `config :neo_faker, locale: ...` (including other async test files).

  alias NeoFaker.Locale

  describe "fetch/0" do
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
        Locale.fetch()
      end
    end
  end

  describe "get/0" do
    test "returns :default when no locale is set" do
      original = Application.get_env(:neo_faker, :locale)

      on_exit(fn ->
        case original do
          nil -> Application.delete_env(:neo_faker, :locale)
          value -> Application.put_env(:neo_faker, :locale, value)
        end
      end)

      Application.delete_env(:neo_faker, :locale)
      assert Locale.get() == :default
    end
  end
end
