defmodule Nf.Hash.Utils do
  @moduledoc false

  @doc """
  Generate a hash.

  Returns a hash based on the hash type and options.
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
