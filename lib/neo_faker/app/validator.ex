defmodule NeoFaker.App.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @name_styles [:camel_case, :pascal_case, :dashed, :underscore, :single]
  @semver_types [:pre_release, :build, :pre_release_build]
  # RFC 1123 label: starts and ends with alphanumeric, allows internal hyphens,
  # 1–63 characters. A valid domain requires at least two such labels (SLD + TLD)
  # and no trailing dot, path separator, port, or other non-label character.
  @domain_label_regex ~r/^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$/

  @doc """
  Validates the app name style option.

  Accepts `nil` or one of `#{inspect([:camel_case, :pascal_case, :dashed, :underscore, :single])}`.
  Raises `ArgumentError` if the style is not valid.
  """
  @spec validate_name_style!(atom() | nil) :: :ok
  def validate_name_style!(nil), do: :ok

  def validate_name_style!(style) do
    valid_styles = [nil | @name_styles]

    case Options.validate_enum(:style, style, valid_styles) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the app name style specifically for bundle IDs.

  Only accepts `:underscore` or `:dashed`. Raises `ArgumentError` for any other value.
  """
  @spec validate_name_style_for_bundle!(atom()) :: :ok
  def validate_name_style_for_bundle!(style) when style in [:underscore, :dashed], do: :ok

  def validate_name_style_for_bundle!(style) do
    raise ArgumentError,
          "Invalid style for bundle_id. Expected one of [:underscore, :dashed], got: #{inspect(style)}"
  end

  @doc """
  Validates the `:domain` option for `bundle_id/1` and `package_name/1`.

  Raises `ArgumentError` when the value is not a valid domain name. A valid domain
  must consist of at least two dot-separated labels, each matching the RFC 1123
  format: starts and ends with an alphanumeric character, contains only letters,
  digits, and hyphens, and is between 1 and 63 characters long. Values with
  trailing dots, path separators (`/`), port suffixes (`:`), or any other
  non-label characters are rejected.
  """
  @spec validate_domain!(String.t()) :: :ok
  def validate_domain!(domain) when is_binary(domain) do
    labels = String.split(domain, ".", trim: false)

    valid =
      length(labels) >= 2 and
        not String.ends_with?(domain, ".") and
        Enum.all?(labels, &Regex.match?(@domain_label_regex, &1))

    if valid do
      :ok
    else
      raise ArgumentError,
            "Invalid domain #{inspect(domain)}. Expected a valid domain with at least two " <>
              "dot-separated labels (e.g. \"example.com\"). Each label must start and end " <>
              "with an alphanumeric character and contain only letters, digits, and hyphens."
    end
  end

  def validate_domain!(domain) do
    raise ArgumentError,
          "Invalid domain #{inspect(domain)}. Expected a binary string, e.g. \"example.com\"."
  end

  @doc """
  Validates the semantic version type option.

  Accepts `nil` or one of `#{inspect([:pre_release, :build, :pre_release_build])}`.
  Raises `ArgumentError` if the type is not valid.
  """
  @spec validate_semver_type!(atom() | nil) :: :ok
  def validate_semver_type!(nil), do: :ok

  def validate_semver_type!(type) do
    valid_types = [nil | @semver_types]

    case Options.validate_enum(:type, type, valid_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
