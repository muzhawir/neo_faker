defmodule NeoFaker.InternetTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Internet

  describe "user_agent/0" do
    test "returns a random user agent" do
      assert is_binary(Internet.user_agent())
    end
  end
end
