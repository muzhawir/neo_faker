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
        nil -> ~r/^[A-Z][a-z0-9]+ [A-Z][a-z0-9]+$/
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
      assert valid_app_name?()
    end

    test "returns an app name for each supported style option" do
      for option <- [:camel_case, :pascal_case, :dashed, :single] do
        assert valid_app_name?(option)
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

    test "raises ArgumentError for an invalid style" do
      assert_raise ArgumentError, fn ->
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

    test "raises ArgumentError when domain has no dot" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "nodot")
      end
    end

    test "raises ArgumentError when domain is empty" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "")
      end
    end

    test "raises ArgumentError when domain is not a string" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: :example)
      end
    end

    test "raises ArgumentError when all domain labels vanish after sanitisation" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "----.----")
      end
    end

    test "raises ArgumentError when domain has a trailing dot" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "example.com.")
      end
    end

    test "raises ArgumentError when domain contains a path separator" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "example.com/path")
      end
    end

    test "raises ArgumentError when domain contains a port suffix" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "example.com:443")
      end
    end

    test "raises ArgumentError when a domain label starts with a hyphen" do
      assert_raise ArgumentError, fn ->
        App.bundle_id(domain: "-example.com")
      end
    end

    test "raises ArgumentError when a domain label ends with a hyphen" do
      assert_raise ArgumentError, fn ->
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

    test "raises ArgumentError when domain has no dot" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "nodot")
      end
    end

    test "raises ArgumentError when domain is empty" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "")
      end
    end

    test "raises ArgumentError when domain is not a string" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: 42)
      end
    end

    test "raises ArgumentError when all domain labels vanish after sanitisation" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "----.----")
      end
    end

    test "raises ArgumentError when domain has a trailing dot" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "example.com.")
      end
    end

    test "raises ArgumentError when domain contains a path separator" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "example.com/path")
      end
    end

    test "raises ArgumentError when domain contains a port suffix" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "example.com:443")
      end
    end

    test "raises ArgumentError when a domain label starts with a hyphen" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "-example.com")
      end
    end

    test "raises ArgumentError when a domain label ends with a hyphen" do
      assert_raise ArgumentError, fn ->
        App.package_name(domain: "example-.com")
      end
    end
  end
end
