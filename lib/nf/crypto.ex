defmodule Nf.Crypto do
  @moduledoc """
  Provides functions for generating cryptographic hashes.

  ## Options

  The accepted options are:

    - `:case` - Specifies the character case of the output.

  The values for `:case` can be:

    - `:lower` (default) - Uses lowercase characters.
    - `:upper` - Uses uppercase characters.
  """
  @moduledoc since: "0.3.1"

  import Nf.Crypto.Utils

  @doc """
  Generates a random MD5 hash.

  Returns a random MD5 hash string.

  See the module documentation for available options.

  ## Examples

      iex> Nf.Crypto.md5()
      "afc4c626c55e4166421d82732163857d"

      iex> Nf.Crypto.md5(case: :upper)
      "AFC4C626C55E4166421D82732163857D"

      iex> Nf.Crypto.md5(2)
      ["afc4c626c55e4166421d82732163857d",
      "9b1c12d90d0aaf8d9b20458fbb24d481"]

  """
  @spec md5(non_neg_integer(), Keyword.t()) :: String.t() | [String.t()]
  def md5(amount \\ 1, opts \\ []), do: generate_hash(amount, :md5, opts)

  @doc """
  Generates a random SHA-1 hash.

  Returns a random SHA-1 hash string.

  See the module documentation for available options.

  ## Examples

      iex> Nf.Crypto.sha1()
      "339fe49a3fd882823ae29263e4873e1a6200ca69"

      iex> Nf.Crypto.sha1(2)
      ["339fe49a3fd882823ae29263e4873e1a6200ca69",
      "c8719790cdfff41c37c75e0c848d2b57535255aa"]

      iex> Nf.Crypto.sha1(case: :upper)
      "339FE49A3FD882823AE29263E4873E1A6200CA69"

  """
  @spec sha1(non_neg_integer(), Keyword.t()) :: String.t() | [String.t()]
  def sha1(amount \\ 1, opts \\ []), do: generate_hash(amount, :sha, opts)

  @doc """
  Generates a random SHA-256 hash.

  Returns a random SHA-256 hash string.

  See the module documentation for available options.

  ## Examples

      iex> Nf.Crypto.sha256()
      "0d2780031e5d677719534fd32d7418c191cc7cecfb392566d8e1206f94631469"

      iex> Nf.Crypto.sha256(2)
      ["0d2780031e5d677719534fd32d7418c191cc7cecfb392566d8e1206f94631469",
      "d0ff021e810fb8f3442a14393604b0661b02f0dfcb347d80c9580af3ab5e7e6c"]

      iex> Nf.Crypto.sha256(case: :upper)
      "0D2780031E5D677719534FD32D7418C191CC7CECFB392566D8E1206F94631469"

  """
  @spec sha256(non_neg_integer(), Keyword.t()) :: String.t() | [String.t()]
  def sha256(amount \\ 1, opts \\ []), do: generate_hash(amount, :sha256, opts)
end
