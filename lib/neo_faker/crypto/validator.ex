defmodule NeoFaker.Crypto.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @case_options [:lower, :upper]
  @hash_types [:md5, :sha1, :sha256, :sha512]

  @doc """
  Validates the `:case` option from the given keyword list.

  Raises `ArgumentError` if the value is not one of `#{inspect([:lower, :upper])}`.
  """
  @spec validate_case_option!(Keyword.t()) :: :ok
  def validate_case_option!(opts) do
    case_opt = Options.get(opts, :case, :lower)

    case Options.validate_enum(:case, case_opt, @case_options) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates that the given hash type is one of the supported algorithms.

  Raises `ArgumentError` if `type` is not one of `#{inspect([:md5, :sha1, :sha256, :sha512])}`.
  """
  @spec validate_hash_type!(atom()) :: :ok
  def validate_hash_type!(type) do
    case Options.validate_enum(:hash_type, type, @hash_types) do
      :ok ->
        :ok

      {:error, _reason} ->
        raise ArgumentError,
              "Invalid hash type. Expected one of #{inspect(@hash_types)}, got: #{inspect(type)}"
    end
  end

  @doc """
  Validates that the given encoding is one of the supported formats.

  Raises `ArgumentError` if `encoding` is not `:base64` or `:hex`.
  """
  @spec validate_encoding!(atom()) :: :ok
  def validate_encoding!(encoding) when encoding in [:base64, :hex], do: :ok

  def validate_encoding!(encoding) do
    raise ArgumentError,
          "Invalid encoding. Expected one of [:base64, :hex], got: #{inspect(encoding)}"
  end

  @doc """
  Validates that the given UUID format is one of the supported formats.

  Raises `ArgumentError` if `format` is not `:standard` or `:compact`.
  """
  @spec validate_uuid_format!(atom()) :: :ok
  def validate_uuid_format!(format) when format in [:standard, :compact], do: :ok

  def validate_uuid_format!(format) do
    raise ArgumentError,
          "Invalid UUID format. Expected one of [:standard, :compact], got: #{inspect(format)}"
  end
end
