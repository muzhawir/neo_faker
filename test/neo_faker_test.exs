defmodule NeoFakerTest do
  use ExUnit.Case, async: true

  describe "locale/0" do
    test "returns current locale" do
      assert is_atom(NeoFaker.locale())
    end
  end

  describe "set_locale/1" do
    test "sets the current locale" do
      assert NeoFaker.set_locale(:id_id) == :ok
    end
  end
end
