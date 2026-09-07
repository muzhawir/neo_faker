defmodule NeoFaker.AppTest do
  use ExUnit.Case, async: true

  alias NeoFaker.App

  defp valid_core_version?(version) do
    integer_in_range? = fn part ->
      case Integer.parse(part) do
        {int, ""} when int in 0..30 -> true
        _ -> false
      end
    end

    version
    |> String.split(".")
    |> Enum.all?(integer_in_range?)
  end

  defp valid_pre_release_identifier?(identifier) do
    case String.split(identifier, ".") do
      [label, number] ->
        label in ~w[alpha beta rc] and
          match?({n, ""} when n in 1..10, Integer.parse(number))

      _ ->
        false
    end
  end

  defp valid_build_number?(number) do
    with <<year::binary-size(4), month::binary-size(2), day::binary-size(2)>> <- number,
         {:ok, _} <- Date.from_iso8601("#{year}-#{month}-#{day}") do
      true
    else
      _ -> false
    end
  end

  defp valid_app_name?(opts \\ nil) do
    regex =
      case opts do
        nil -> ~r/^[A-Z][A-Za-z0-9]* [A-Z][A-Za-z0-9]*$/
        :camel_case -> ~r/^[a-z]+(?:[A-Z][a-z0-9]*)*$/
        :pascal_case -> ~r/^[A-Z][a-z0-9]*(?:[A-Z][a-z0-9]*)*$/
        :dashed -> ~r/^[a-zA-Z]+(?:-[a-zA-Z0-9]+)*$/
        :single -> ~r/^[A-Z]?[a-z0-9]+$/
      end

    Regex.match?(regex, App.name(style: opts))
  end

  defp assert_semver_pre_release do
    [core, pre] = String.split(App.semver(type: :pre_release), "-")

    assert valid_core_version?(core)
    assert valid_pre_release_identifier?(pre)
  end

  defp assert_semver_build do
    [core, build] = String.split(App.semver(type: :build), "+")

    assert valid_core_version?(core)
    assert valid_build_number?(build)
  end

  defp assert_semver_pre_release_build do
    [core, rest] = String.split(App.semver(type: :pre_release_build), "-")
    [pre, build] = String.split(rest, "+")

    assert valid_core_version?(core)
    assert valid_pre_release_identifier?(pre)
    assert valid_build_number?(build)
  end

  describe "author/0" do
    test "returns a valid string for app author" do
      assert String.valid?(App.author())
    end
  end

  describe "description/0" do
    test "returns a valid string for app description" do
      assert String.valid?(App.description())
    end
  end

  describe "license/0" do
    test "returns a valid string for an open source license" do
      assert String.valid?(App.license())
    end
  end

  describe "name/2" do
    test "returns an app name in default format" do
      # Loop: name parts are drawn at random and include the all-caps "AI".
      for _ <- 1..100, do: assert(valid_app_name?())
    end

    test "returns an app name for each supported style option" do
      for option <- [:camel_case, :pascal_case, :dashed, :single], _ <- 1..50 do
        assert valid_app_name?(option), "invalid #{option} app name"
      end
    end
  end

  describe "semver/1" do
    test "returns a valid semantic version number" do
      assert valid_core_version?(App.semver())
    end

    test "returns a semantic version number with pre-release identifier" do
      assert_semver_pre_release()
    end

    test "returns a semantic version number with build metadata" do
      assert_semver_build()
    end

    test "returns a semantic version number with pre-release identifier and build metadata" do
      assert_semver_pre_release_build()
    end
  end

  describe "version/0" do
    test "returns a valid version number" do
      assert valid_core_version?(App.version())
    end
  end

  describe "bundle_id/1" do
    test "returns a bundle ID in reverse-domain notation with default domain" do
      bundle = App.bundle_id()

      assert String.starts_with?(bundle, "com.example.")
      assert String.match?(bundle, ~r/^com\.example\.[a-z0-9_]+$/)
    end

    test "returns a bundle ID with a custom domain" do
      bundle = App.bundle_id(domain: "mycompany.io")

      assert String.starts_with?(bundle, "io.mycompany.")
    end

    test "returns a dashed bundle ID when style: :dashed" do
      bundle = App.bundle_id(style: :dashed)

      assert String.match?(bundle, ~r/^com\.example\.[a-z0-9-]+$/)
    end

    test "returns an underscored bundle ID when style: :underscore" do
      bundle = App.bundle_id(style: :underscore)

      assert String.match?(bundle, ~r/^com\.example\.[a-z0-9_]+$/)
    end

    test "raises NimbleOptions.ValidationError for an invalid style" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(style: :pascal_case)
      end
    end

    test "sanitises hyphenated domain labels into alphanumeric-only components" do
      bundle = App.bundle_id(domain: "my-company.io")

      # "my-company" → "mycompany" after stripping the hyphen
      assert String.starts_with?(bundle, "io.mycompany.")
      assert String.match?(bundle, ~r/^io\.mycompany\.[a-z0-9_]+$/)
    end

    test "sanitises mixed-case domain labels to lowercase" do
      bundle = App.bundle_id(domain: "MyCompany.IO")

      assert String.starts_with?(bundle, "io.mycompany.")
    end

    test "sanitises numeric-only domain labels" do
      bundle = App.bundle_id(domain: "123corp.com")

      assert String.starts_with?(bundle, "com.123corp.")
    end

    test "raises NimbleOptions.ValidationError when domain has no dot" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "nodot")
      end
    end

    test "raises NimbleOptions.ValidationError when domain is empty" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "")
      end
    end

    test "raises NimbleOptions.ValidationError when domain is not a string" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: :example)
      end
    end

    test "raises NimbleOptions.ValidationError when all domain labels vanish after sanitisation" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "----.----")
      end
    end

    test "raises NimbleOptions.ValidationError when domain has a trailing dot" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "example.com.")
      end
    end

    test "raises NimbleOptions.ValidationError when domain contains a path separator" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "example.com/path")
      end
    end

    test "raises NimbleOptions.ValidationError when domain contains a port suffix" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "example.com:443")
      end
    end

    test "raises NimbleOptions.ValidationError when a domain label starts with a hyphen" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "-example.com")
      end
    end

    test "raises NimbleOptions.ValidationError when a domain label ends with a hyphen" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.bundle_id(domain: "example-.com")
      end
    end
  end

  describe "package_name/1" do
    test "returns a package name in reverse-domain notation with default domain" do
      package = App.package_name()

      assert String.starts_with?(package, "com.example.")
      assert String.match?(package, ~r/^com\.example\.[a-z0-9]+$/)
    end

    test "returns a package name with a custom domain" do
      package = App.package_name(domain: "mycompany.id")

      assert String.starts_with?(package, "id.mycompany.")
    end

    test "returns a package name with only lowercase alphanumeric characters" do
      package = App.package_name()
      app_segment = package |> String.split(".") |> List.last()

      assert String.match?(app_segment, ~r/^[a-z0-9]+$/)
    end

    test "sanitises hyphenated domain labels into alphanumeric-only components" do
      package = App.package_name(domain: "my-company.io")

      # "my-company" → "mycompany" after stripping the hyphen
      assert String.starts_with?(package, "io.mycompany.")
      assert String.match?(package, ~r/^io\.mycompany\.[a-z0-9]+$/)
    end

    test "sanitises mixed-case domain labels to lowercase" do
      package = App.package_name(domain: "MyCompany.IO")

      assert String.starts_with?(package, "io.mycompany.")
    end

    test "sanitises subdomain labels and reverses all of them" do
      package = App.package_name(domain: "my-app.my-company.io")

      # "my-app" → "myapp", "my-company" → "mycompany", reversed: io.mycompany.myapp
      assert String.starts_with?(package, "io.mycompany.myapp.")
      assert String.match?(package, ~r/^io\.mycompany\.myapp\.[a-z0-9]+$/)
    end

    test "domain labels in package name contain only alphanumeric characters" do
      package = App.package_name(domain: "my-company.co.id")

      # All label components must be pure [a-z0-9]
      domain_segments = package |> String.split(".") |> Enum.drop(-1)

      assert Enum.all?(domain_segments, &String.match?(&1, ~r/^[a-z0-9]+$/)),
             "expected all domain label segments to be alphanumeric, got: #{inspect(domain_segments)}"
    end

    test "raises NimbleOptions.ValidationError when domain has no dot" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "nodot")
      end
    end

    test "raises NimbleOptions.ValidationError when domain is empty" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "")
      end
    end

    test "raises NimbleOptions.ValidationError when domain is not a string" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: 42)
      end
    end

    test "raises NimbleOptions.ValidationError when all domain labels vanish after sanitisation" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "----.----")
      end
    end

    test "raises NimbleOptions.ValidationError when domain has a trailing dot" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "example.com.")
      end
    end

    test "raises NimbleOptions.ValidationError when domain contains a path separator" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "example.com/path")
      end
    end

    test "raises NimbleOptions.ValidationError when domain contains a port suffix" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "example.com:443")
      end
    end

    test "raises NimbleOptions.ValidationError when a domain label starts with a hyphen" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "-example.com")
      end
    end

    test "raises NimbleOptions.ValidationError when a domain label ends with a hyphen" do
      assert_raise NimbleOptions.ValidationError, fn ->
        App.package_name(domain: "example-.com")
      end
    end
  end

  describe "author/1" do
    test "omits the middle name by default" do
      assert App.author() |> String.split() |> length() == 2
    end

    test "includes a middle name when middle_name: true" do
      assert [middle_name: true] |> App.author() |> String.split() |> length() == 3
    end

    test "accepts a sex option" do
      assert String.valid?(App.author(sex: :female))
    end
  end

  describe "name/2 remaining styles" do
    test "returns an underscored lowercase name when style: :underscore" do
      assert String.match?(App.name(style: :underscore), ~r/^[a-z0-9]+_[a-z0-9]+$/)
    end

    test "returns a single capitalised word when style: :single" do
      assert String.match?(App.name(style: :single), ~r/^[A-Z][a-z0-9]*$/)
    end

    test "returns a title-spaced name when style is nil" do
      assert App.name() |> String.split() |> length() == 2
    end

    test "raises NimbleOptions.ValidationError for an unknown style" do
      assert_raise NimbleOptions.ValidationError, fn -> App.name(style: :kebab) end
    end
  end

  describe "semver/1 option validation" do
    test "raises NimbleOptions.ValidationError for an unknown type" do
      assert_raise NimbleOptions.ValidationError, fn -> App.semver(type: :nightly) end
    end
  end

  describe "NameGenerator.format_text/2" do
    alias NeoFaker.App.NameGenerator

    test "formats a name for every style" do
      pair = {"neo", "faker"}

      assert NameGenerator.format_text(pair, nil) == "neo faker"
      assert NameGenerator.format_text(pair, :camel_case) == "neoFaker"
      assert NameGenerator.format_text(pair, :pascal_case) == "NeoFaker"
      assert NameGenerator.format_text(pair, :dashed) == "Neo-faker"
      assert NameGenerator.format_text(pair, :underscore) == "neo_faker"
      assert NameGenerator.format_text(pair, :single) in ["Neo", "Faker"]
    end
  end

  describe "DomainGenerator.reverse_domain!/1" do
    alias NeoFaker.App.DomainGenerator

    test "reverses and sanitises labels" do
      assert DomainGenerator.reverse_domain!("example.com") == "com.example"
      assert DomainGenerator.reverse_domain!("My-Company.IO") == "io.mycompany"
      assert DomainGenerator.reverse_domain!("a.b.c") == "c.b.a"
    end

    test "raises ArgumentError when every label is empty after sanitisation" do
      assert_raise ArgumentError, ~r/produced no valid labels/, fn ->
        DomainGenerator.reverse_domain!("...")
      end
    end
  end

  describe "SemverGenerator" do
    alias NeoFaker.App.SemverGenerator

    test "semver_core/0 is MAJOR.MINOR.PATCH within the documented ranges" do
      [major, minor, patch] =
        SemverGenerator.semver_core() |> String.split(".") |> Enum.map(&String.to_integer/1)

      assert major in 0..9 and minor in 0..20 and patch in 1..30
    end

    test "semver_pre_release/0 is label.N" do
      [label, n] = String.split(SemverGenerator.semver_pre_release(), ".")

      assert label in ~w[alpha beta rc]
      assert String.to_integer(n) in 1..10
    end

    test "semver_build_number/0 is an 8-digit YYYYMMDD string" do
      assert String.match?(SemverGenerator.semver_build_number(), ~r/^\d{8}$/)
    end
  end
end
