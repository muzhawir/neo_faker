defmodule NF.GravatarTest do
  use ExUnit.Case

  describe "display/2" do
    test "returns a Gravatar URL based on an email address" do
      url_result =
        "https://gravatar.com/avatar/a379a6f6eeafb9a55e378c118034e2751e682fab9f2d30ab13d2125586ce1947?d=identicon&s=80"

      assert NF.Gravatar.display("example.com") == url_result
    end

    test "returns a Gravatar URL based on an email address with custom size" do
      url_result =
        "https://gravatar.com/avatar/a379a6f6eeafb9a55e378c118034e2751e682fab9f2d30ab13d2125586ce1947?d=identicon&s=100"

      assert NF.Gravatar.display("example.com", size: 100) == url_result
    end

    test "returns a Gravatar URL based on an email address with custom fallback" do
      url_result =
        "https://gravatar.com/avatar/a379a6f6eeafb9a55e378c118034e2751e682fab9f2d30ab13d2125586ce1947?d=monsterid&s=80"

      assert NF.Gravatar.display("example.com", fallback: "monsterid") == url_result
    end
  end
end
