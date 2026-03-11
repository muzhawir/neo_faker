defmodule NeoFaker.App.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @name_styles [:camel_case, :pascal_case, :dashed, :underscore, :single]
  @semver_types [:pre_release, :build, :pre_release_build]
  @domain_regex ~r/^[^.\s]+\.[^.\s]/

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

  Raises `ArgumentError` when the value is blank or does not contain at least one dot
  with non-empty labels on both sides, which would cause the reverse-domain split to
  produce a `MatchError` at runtime.
  """
  @spec validate_domain!(String.t()) :: :ok
  def validate_domain!(domain) when is_binary(domain) do
    if Regex.match?(@domain_regex, domain) do
      :ok
    else
      raise ArgumentError,
            "Invalid domain #{inspect(domain)}. Expected a domain with at least one dot " <>
              "and non-empty labels on both sides, e.g. \"example.com\"."
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
