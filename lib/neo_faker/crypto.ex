defmodule NeoFaker.Crypto do
  @moduledoc """
  Provides functions for generating cryptographic hashes.

  This module includes functions for generating various types of cryptographic hash values,
  such as MD5 and SHA-based hashes.
  """
  @moduledoc since: "0.3.1"

  import NeoFaker.Crypto.Util

  @doc """
  Generates a random MD5 hash.

  Returns a random MD5 hash string.

  ## Options

  The accepted options are:

  - `:case` - Specifies the character case of the output.

  The values for `:case` can be:

  - `:lower` - Uses lowercase characters (default).
  - `:upper` - Uses uppercase characters.

  ## Examples

      iex> NeoFaker.Crypto.md5()
      "afc4c626c55e4166421d82732163857d"

      iex> NeoFaker.Crypto.md5(case: :upper)
      "AFC4C626C55E4166421D82732163857D"

  """
  @spec md5(Keyword.t()) :: String.t()
  def md5(opts \\ []), do: generate_hash(:md5, opts)

  @doc """
  Generates a random SHA-1 hash.

  This function behaves the same way as `md5/1`. See `md5/1` for more details.
  """
  @spec sha1(Keyword.t()) :: String.t()
  def sha1(opts \\ []), do: generate_hash(:sha, opts)

  @doc """
  Generates a random SHA-256 hash.

  This function behaves the same way as `md5/1`. See `md5/1` for more details.
  """
  @spec sha256(Keyword.t()) :: String.t()
  def sha256(opts \\ []), do: generate_hash(:sha256, opts)
end
