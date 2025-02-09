defmodule Nf.Crypto.Utils do
  @moduledoc false

  @doc """
  Generates a cryptographic hash.

  This function computes a hash using the specified algorithm and applies optional transformations,
  such as case formatting.

  ## Parameters

  - `hash_type` - The hashing algorithm to use (e.g., `:md5`, `:sha1`, `:sha256`).
  - `options` - A list of options to modify the hash output.

  ## Options

  The accepted options are:

  - `:case` - Determines whether the hash is returned in lowercase or uppercase.

  The values for `:case` can be:

  - `:upper` - uses upper case characters (default)
  - `:lower` - uses lower case characters

  """
  @spec generate_hash(atom(), Keyword.t()) :: String.t()
  def generate_hash(hash_type, opts) do
    character_case =
      case Keyword.get(opts, :case) do
        :upper -> :upper
        _ -> :lower
      end

    data = :crypto.strong_rand_bytes(16)

    hash_type |> :crypto.hash(data) |> Base.encode16(case: character_case)
  end
end
