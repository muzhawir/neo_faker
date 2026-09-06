defmodule NeoFaker.Crypto.Validator do
  @moduledoc false

  @hash_types [:md5, :sha1, :sha256, :sha512]

  @doc """
  Validates that the given hash type is one of the supported algorithms.

  Raises `ArgumentError` if `type` is not one of `#{inspect([:md5, :sha1, :sha256, :sha512])}`.
  """
  @spec validate_hash_type!(atom()) :: :ok
  def validate_hash_type!(type) when type in @hash_types, do: :ok

  def validate_hash_type!(type) do
    raise ArgumentError,
          "Invalid hash type. Expected one of #{inspect(@hash_types)}, got: #{inspect(type)}"
  end
end
