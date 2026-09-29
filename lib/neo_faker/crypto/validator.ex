defmodule NeoFaker.Crypto.Validator do
  @moduledoc false

  @hash_types [:md5, :sha1, :sha256, :sha512]

  @doc """
  Returns `:ok` if `type` is a supported hash type, raising `ArgumentError` otherwise.
  """
  @spec validate_hash_type!(term()) :: :ok
  def validate_hash_type!(type) when type in @hash_types, do: :ok

  def validate_hash_type!(type) do
    raise ArgumentError,
          "invalid hash type #{inspect(type)}, expected one of #{inspect(@hash_types)}"
  end
end
