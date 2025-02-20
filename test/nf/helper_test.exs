defmodule Nf.HelperTest do
  use ExUnit.Case, async: true

  describe "build_locale_path/3" do
    test "builds the absolute path to a locale-specific file" do
      result = File.cwd!() <> "/lib/data/default/app/author.exs"

      assert Nf.Helper.build_locale_path("default", "app", "author.exs") == result
    end
  end

  describe "read_locale_file/2" do
    test "reads a locale-specific file and returns its content as a map" do
      assert is_map(Nf.Helper.read_locale_file("app", "author.exs"))
    end
  end
end
