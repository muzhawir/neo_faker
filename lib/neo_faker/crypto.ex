defmodule NeoFaker.Crypto do
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

  import NeoFaker.Crypto.Utils

  @doc """
  Generates a random MD5 hash.

  Returns a random MD5 hash string.

  See the module documentation for available options.

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

  Returns a random SHA-1 hash string.

  See the module documentation for available options.

  ## Examples

      iex> NeoFaker.Crypto.sha1()
      "339fe49a3fd882823ae29263e4873e1a6200ca69"

      iex> NeoFaker.Crypto.sha1(case: :upper)
      "339FE49A3FD882823AE29263E4873E1A6200CA69"

  """
  @spec sha1(Keyword.t()) :: String.t()
  def sha1(opts \\ []), do: generate_hash(:sha, opts)

  @doc """
  Generates a random SHA-256 hash.

  Returns a random SHA-256 hash string.

  See the module documentation for available options.

  ## Examples

      iex> NeoFaker.Crypto.sha256()
      "0d2780031e5d677719534fd32d7418c191cc7cecfb392566d8e1206f94631469"

      iex> NeoFaker.Crypto.sha256(case: :upper)
      "0D2780031E5D677719534FD32D7418C191CC7CECFB392566D8E1206F94631469"

  """
  @spec sha256(Keyword.t()) :: String.t()
  def sha256(opts \\ []), do: generate_hash(:sha256, opts)
end
