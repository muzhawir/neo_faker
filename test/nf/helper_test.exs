defmodule Nf.HelperTest do
  use ExUnit.Case, async: true

  describe "get_data_path/0" do
    test "returns a path to the `priv/lib` directory" do
      assert Nf.Helper.get_data_path() == Path.join([File.cwd!(), "lib", "data"])
    end
  end
end
