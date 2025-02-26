defmodule NeoFaker.Crypto.Util do
  @moduledoc false

  @doc """
  Generates a cryptographic hash.

  This function computes a hash using the specified algorithm and applies optional transformations,
  such as case formatting.

  ## Parameters

  - `amount` - The number of hashes to generate.
  - `hash_type` - The hashing algorithm to use (e.g., `:md5`, `:sha`, `:sha256`).
  - `options` - A list of options to modify the hash output.

  ## Options

  The accepted options are:

  - `:case` - Determines whether the hash is returned in lowercase or uppercase.

  The values for `:case` can be:

  - `:upper` - uses upper case characters

  """
  @spec generate_hash(atom(), Keyword.t()) :: String.t() | [String.t()]
  def generate_hash(hash_type, opts) do
    case_type = Keyword.get(opts, :case, :lower)
    random_byte = :crypto.strong_rand_bytes(16)

    hash_type |> :crypto.hash(random_byte) |> Base.encode16(case: case_type)
  end
end
