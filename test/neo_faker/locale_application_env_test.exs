defmodule NeoFaker.LocaleApplicationEnvTest do
  use ExUnit.Case, async: false

  # `Application.put_env/3` and `Application.delete_env/2` mutate node-global state, not
  # process-scoped state, so these tests must not run concurrently with anything else that
  # reads `config :neo_faker, locale: ...` (including other async test files).

  alias NeoFaker.Locale

  setup do
    original = Application.get_env(:neo_faker, :locale)

    on_exit(fn ->
      case original do
        nil -> Application.delete_env(:neo_faker, :locale)
        value -> Application.put_env(:neo_faker, :locale, value)
      end
    end)

    :ok
  end

  describe "fetch/0 reading from application env" do
    test "returns {:ok, :default} when the configured locale is :default" do
      Application.put_env(:neo_faker, :locale, :default)

      assert Locale.fetch() == {:ok, :default}
    end

    test "returns {:ok, locale} for a supported configured locale" do
      Application.put_env(:neo_faker, :locale, :id_id)

      assert Locale.fetch() == {:ok, :id_id}
    end

    test "returns :error when no locale is configured" do
      Application.delete_env(:neo_faker, :locale)

      assert Locale.fetch() == :error
    end

    test "raises ArgumentError when a bogus atom is stored directly" do
      Application.put_env(:neo_faker, :locale, :bogus_locale)

      assert_raise ArgumentError, ~r/Unsupported locale :bogus_locale/, fn -> Locale.fetch() end
    end

    test "raises ArgumentError when a non-atom is stored directly" do
      Application.put_env(:neo_faker, :locale, "id_id")

      assert_raise ArgumentError, ~r/Invalid locale format/, fn -> Locale.fetch() end
    end
  end

  describe "NeoFaker.start/0" do
    test "falls back to :default and returns :ok when no locale is configured" do
      Application.delete_env(:neo_faker, :locale)
      Process.delete({Locale, :locale})

      assert ExUnit.CaptureIO.capture_io(fn -> assert NeoFaker.start() == :ok end) =~
               "locale: :default"

      assert Locale.get() == :default
    end

    test "returns :ok when a locale is already configured" do
      Application.put_env(:neo_faker, :locale, :default)

      assert ExUnit.CaptureIO.capture_io(fn -> assert NeoFaker.start() == :ok end) =~ "NeoFaker"
    end
  end

  describe "get/0 reading from application env" do
    test "returns :default when no locale is set" do
      Application.delete_env(:neo_faker, :locale)

      assert Locale.get() == :default
    end

    test "returns the configured supported locale" do
      Application.put_env(:neo_faker, :locale, :id_id)

      assert Locale.get() == :id_id
    end
  end
end
