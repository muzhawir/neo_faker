defmodule NeoFaker.GravatarTest do
  use ExUnit.Case, async: true

  describe "display/2" do
    test "returns a Gravatar URL" do
      url_result =
        "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=identicon&s=80"

      assert NeoFaker.Gravatar.display("john.doe@example.com") == url_result
    end

    test "returns a Gravatar URL with custom size" do
      url_result =
        "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=identicon&s=100"

      assert NeoFaker.Gravatar.display("john.doe@example.com", size: 100) == url_result
    end

    test "returns a Gravatar URL with custom fallback" do
      url_result =
        "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=monsterid&s=80"

      assert NeoFaker.Gravatar.display("john.doe@example.com", fallback: :monsterid) == url_result
    end
  end
end
