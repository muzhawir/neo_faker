defmodule NeoFaker.GravatarTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Gravatar

  @john_doe_email "john.doe@example.com"
  @john_doe_hashed_url "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f"

  # Matches a full 64-char lowercase hex SHA-256 hash in a Gravatar URL path
  @gravatar_image_url_regexp ~r|^https://gravatar\.com/avatar/[0-9a-f]{64}|
  @gravatar_profile_url_regexp ~r|^https://gravatar\.com/[0-9a-f]{64}|

  # ---------------------------------------------------------------------------
  # display/2
  # ---------------------------------------------------------------------------

  describe "display/2" do
    test "returns a Gravatar URL with default size and fallback" do
      expected = "#{@john_doe_hashed_url}?d=identicon&s=80"

      assert Gravatar.display(@john_doe_email) == expected
    end

    test "returns a Gravatar URL with a custom size" do
      expected = "#{@john_doe_hashed_url}?d=identicon&s=100"

      assert Gravatar.display(@john_doe_email, size: 100) == expected
    end

    test "returns a Gravatar URL with a custom fallback atom" do
      expected = "#{@john_doe_hashed_url}?d=monsterid&s=80"

      assert Gravatar.display(@john_doe_email, fallback: :monsterid) == expected
    end

    test "returns a Gravatar URL for each supported fallback type" do
      for fallback <- Gravatar.fallback_types() do
        url = Gravatar.display(@john_doe_email, fallback: fallback)

        assert String.contains?(url, "d=#{fallback}")
      end
    end

    test "returns a Gravatar URL with a custom fallback URL string" do
      custom_url = "https://example.com/default.png"
      url = Gravatar.display(@john_doe_email, fallback: custom_url)

      assert String.contains?(url, "d=#{custom_url}")
    end

    test "returns a Gravatar URL with a rating parameter" do
      for rating <- [:g, :pg, :r, :x] do
        url = Gravatar.display(@john_doe_email, rating: rating)

        assert String.contains?(url, "&r=#{rating}"),
               "expected URL to contain &r=#{rating}, got: #{url}"
      end
    end

    test "returns a Gravatar URL without a rating parameter when rating is nil" do
      url = Gravatar.display(@john_doe_email)

      refute String.contains?(url, "&r=")
    end

    test "returns a Gravatar URL with force_default parameter when force_default: true" do
      url = Gravatar.display(@john_doe_email, force_default: true)

      assert String.ends_with?(url, "&f=y")
    end

    test "returns a Gravatar URL without force_default parameter by default" do
      url = Gravatar.display(@john_doe_email)

      refute String.contains?(url, "&f=")
    end

    test "returns a Gravatar URL with rating and force_default combined" do
      url = Gravatar.display(@john_doe_email, rating: :pg, force_default: true)

      assert String.contains?(url, "&r=pg")
      assert String.ends_with?(url, "&f=y")
    end

    test "returns a valid Gravatar URL when email is nil" do
      url = Gravatar.display(nil)

      assert String.match?(url, @gravatar_image_url_regexp)
    end

    test "returns a URL that starts with the Gravatar base URL" do
      url = Gravatar.display(@john_doe_email)

      assert String.starts_with?(url, "https://gravatar.com/avatar/")
    end

    test "returns a URL containing the required query string parameters" do
      url = Gravatar.display(@john_doe_email)

      assert String.contains?(url, "?d=")
      assert String.contains?(url, "&s=")
    end

    test "raises NimbleOptions.ValidationError when size is below 1" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, size: 0)
      end
    end

    test "raises NimbleOptions.ValidationError when size is above 2048" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, size: 2049)
      end
    end

    test "raises NimbleOptions.ValidationError when size is not an integer" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, size: "large")
      end
    end

    test "raises NimbleOptions.ValidationError when fallback is an unknown atom" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, fallback: :unknown)
      end
    end

    test "raises NimbleOptions.ValidationError when fallback string does not start with http:// or https://" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, fallback: "ftp://example.com/img.png")
      end
    end

    test "raises NimbleOptions.ValidationError when fallback is neither an atom nor a string" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, fallback: 42)
      end
    end

    test "raises NimbleOptions.ValidationError when rating is an invalid atom" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.display(@john_doe_email, rating: :nc17)
      end
    end

    test "raises ArgumentError when email is not a valid address" do
      assert_raise ArgumentError, fn ->
        Gravatar.display("not-an-email")
      end
    end
  end

  # ---------------------------------------------------------------------------
  # profile/2
  # ---------------------------------------------------------------------------

  describe "profile/2" do
    test "returns a Gravatar profile URL in HTML format by default" do
      url = Gravatar.profile(@john_doe_email)

      assert String.match?(url, @gravatar_profile_url_regexp)
      refute String.ends_with?(url, ~w(.json .xml .php .vcf .qr))
    end

    test "returns a Gravatar profile URL for each supported format" do
      format_extensions = %{
        json: ".json",
        xml: ".xml",
        php: ".php",
        vcf: ".vcf",
        qr: ".qr"
      }

      for {format, extension} <- format_extensions do
        url = Gravatar.profile(@john_doe_email, format: format)

        assert String.ends_with?(url, extension),
               "expected URL to end with #{extension}, got: #{url}"
      end
    end

    test "returns an HTML profile URL without a file extension" do
      url = Gravatar.profile(@john_doe_email, format: :html)

      assert String.match?(url, @gravatar_profile_url_regexp)
      refute String.ends_with?(url, ".html")
    end

    test "returns a valid Gravatar profile URL when email is nil" do
      url = Gravatar.profile(nil)

      assert String.match?(url, @gravatar_profile_url_regexp)
    end

    test "returns a URL starting with the Gravatar base URL" do
      url = Gravatar.profile(@john_doe_email)

      assert String.starts_with?(url, "https://gravatar.com/")
    end

    test "raises NimbleOptions.ValidationError for an unsupported profile format" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Gravatar.profile(@john_doe_email, format: :yaml)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # random_display/0
  # ---------------------------------------------------------------------------

  describe "random_display/0" do
    test "returns a valid Gravatar image URL" do
      url = Gravatar.random_display()

      assert String.match?(url, @gravatar_image_url_regexp)
    end

    test "returns a URL with a query string" do
      url = Gravatar.random_display()

      assert String.contains?(url, "?d=")
      assert String.contains?(url, "&s=")
    end

    test "returns a different URL on repeated calls" do
      urls = Enum.map(1..10, fn _ -> Gravatar.random_display() end)

      assert urls |> Enum.uniq() |> length() > 1
    end
  end

  # ---------------------------------------------------------------------------
  # random/0 (deprecated)
  # ---------------------------------------------------------------------------

  describe "random/0 (deprecated, delegates to random_display/0)" do
    test "returns a valid Gravatar image URL" do
      url = Gravatar.random()

      assert String.match?(url, @gravatar_image_url_regexp)
    end
  end

  # ---------------------------------------------------------------------------
  # fallback_types/0
  # ---------------------------------------------------------------------------

  describe "fallback_types/0" do
    test "returns a non-empty list of atoms" do
      types = Gravatar.fallback_types()

      assert is_list(types)
      refute Enum.empty?(types)
      assert Enum.all?(types, &is_atom/1)
    end

    test "includes all documented fallback types" do
      assert Gravatar.fallback_types() ==
               [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]
    end
  end

  # ---------------------------------------------------------------------------
  # default_size/0
  # ---------------------------------------------------------------------------

  describe "default_size/0" do
    test "returns 80" do
      assert Gravatar.default_size() == 80
    end

    test "returns a positive integer within the valid size range" do
      size = Gravatar.default_size()

      assert is_integer(size)
      assert size in Gravatar.size_range()
    end
  end

  # ---------------------------------------------------------------------------
  # size_range/0
  # ---------------------------------------------------------------------------

  describe "size_range/0" do
    test "returns 1..2048" do
      assert Gravatar.size_range() == 1..2048
    end

    test "returns a Range where first is 1 and last is 2048" do
      range = Gravatar.size_range()

      assert range.first == 1
      assert range.last == 2048
    end
  end
end
