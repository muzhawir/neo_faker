defmodule NeoFaker.GravatarTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Gravatar

  @john_doe_email "john.doe@example.com"
  @john_doe_hashed_url "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f"

  describe "display/2" do
    test "returns a Gravatar URL with default size and fallback" do
      expected = "#{@john_doe_hashed_url}?d=identicon&s=80"

      assert Gravatar.display(@john_doe_email) == expected
    end

    test "returns a Gravatar URL with a custom size" do
      expected = "#{@john_doe_hashed_url}?d=identicon&s=100"

      assert Gravatar.display(@john_doe_email, size: 100) == expected
    end

    test "returns a Gravatar URL with a custom fallback" do
      expected = "#{@john_doe_hashed_url}?d=monsterid&s=80"

      assert Gravatar.display(@john_doe_email, fallback: :monsterid) == expected
    end

    test "returns a URL that starts with the Gravatar base URL" do
      url = Gravatar.display(@john_doe_email)

      assert String.starts_with?(url, "https://gravatar.com/avatar/")
    end

    test "returns a URL containing the query string parameters" do
      url = Gravatar.display(@john_doe_email)

      assert String.contains?(url, "?d=")
      assert String.contains?(url, "&s=")
    end
  end
end
