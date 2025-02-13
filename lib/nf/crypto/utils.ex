defmodule Nf.Crypto.Utils do
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
  @spec generate_hash(non_neg_integer(), atom(), Keyword.t()) :: String.t() | [String.t()]
  def generate_hash(amount \\ 1, hash_type, opts \\ [])
  def generate_hash(1, hash_type, opts), do: generate_hashed_value(hash_type, opts)

  def generate_hash(amount, hash_type, opts) when amount > 1 do
    for _ <- 1..amount, do: generate_hashed_value(hash_type, opts)
  end

  defp generate_hashed_value(hash_type, opts) do
    data = :crypto.strong_rand_bytes(16)
    case_type = Keyword.get(opts, :case, :lower)

    hash_type |> :crypto.hash(data) |> Base.encode16(case: case_type)
  end
end
