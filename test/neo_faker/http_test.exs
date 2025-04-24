defmodule NeoFaker.HttpTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Http

  describe "user_agent/0" do
    test "returns a random user agent" do
      assert is_binary(Http.user_agent())
    end
  end
end
