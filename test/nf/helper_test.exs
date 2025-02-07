defmodule Nf.HelperTest do
  use ExUnit.Case, async: true

  describe "get_priv_lib_path" do
    test "returns the path to the `priv/lib` directory" do
      assert Nf.Helper.get_priv_lib_path() == Path.join([File.cwd!(), "priv", "lib"])
    end
  end
end
