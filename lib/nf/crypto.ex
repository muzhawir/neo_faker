defmodule Nf.Crypto do
  @moduledoc """
  Provides functions for generating cryptographic hashes.

  Each function returns a hash string and supports the following option:

    - `:case` - Specifies the character case of the output.
      - `:lower` (default) - Uses lowercase characters.
      - `:upper` - Uses uppercase characters.

  ## Examples

      iex> Nf.Crypto.md5()
      "e35cb102765cfc56df21ba4c16e6a636"

      iex> Nf.Crypto.sha256("hello", case: :upper)
      "2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824"

  """
  @moduledoc since: "0.3.1"

  import Nf.Crypto.Utils

  @doc """
  Generates an MD5 hash.

  Returns an MD5 hash string.

  See the module documentation for available options.

  ## Examples

      iex> Nf.Hash.md5()
      "e35cb102765cfc56df21ba4c16e6a636"

  """
  @spec md5(Keyword.t()) :: String.t()
  def md5(opts \\ []), do: generate_hash(:md5, opts)

  @doc """
  Generates an SHA-1 hash.

  Returns an SHA-1 hash string.

  See the module documentation for available options.

  ## Examples

      iex> Nf.Hash.sha1()
      "c8719790cdfff41c37c75e0c848d2b57535255aa"

  """
  @spec sha1(Keyword.t()) :: String.t()
  def sha1(opts \\ []), do: generate_hash(:sha, opts)

  @doc """
  Generates an SHA-256 hash.

  Returns an SHA-256 hash string.

  See the module documentation for available options.

  ## Examples

      iex> Nf.Hash.sha256()
      "d0ff021e810fb8f3442a14393604b0661b02f0dfcb347d80c9580af3ab5e7e6c"

  """
  @spec sha256(Keyword.t()) :: String.t()
  def sha256(opts \\ []), do: generate_hash(:sha256, opts)
end
