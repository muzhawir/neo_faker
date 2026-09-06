defmodule NeoFaker.Crypto.HashGenerator do
  @moduledoc false

  @doc """
  Generates a cryptographic hash using the given algorithm.

  `hash_type` is any algorithm accepted by `:crypto.hash/2` (e.g. `:md5`, `:sha`, `:sha256`).

  ## Options

    * `:case` (`:lower` or `:upper`) - the output character case. Defaults to `:lower`.

  """
  @spec generate_hash(atom(), keyword()) :: String.t()
  def generate_hash(hash_type, opts \\ []) do
    case_type = Keyword.get(opts, :case, :lower)
    random_bytes = :crypto.strong_rand_bytes(16)

    hash_type |> :crypto.hash(random_bytes) |> Base.encode16(case: case_type)
  end
end
