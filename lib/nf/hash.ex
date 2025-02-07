defmodule Nf.Hash do
  @moduledoc """
  Functions to generate random hashes.
  """
  @moduledoc since: "0.3.1"

  @doc """
  Generate a random MD5 hash.

  Returns an MD5 hash like `e35cb102765cfc56df21ba4c16e6a636`.

  ## Options

  The accepted options are:

  - `:case` - specifies the character case output

  The values for :case can be:
  - `:lower` - uses lower case characters (default)
  - `:upper` - uses upper case characters

  ## Examples

      iex> Nf.Hash.md5()
      "e35cb102765cfc56df21ba4c16e6a636"

      iex> Nf.Hash.md5(case: :upper)
      "E35CB102765CFC56DF21BA4C16E6A636"

  """
  @spec md5(Keyword.t()) :: String.t()
  def md5(options \\ []), do: generate_hash(:md5, options)

  @doc """
  Generate a random SHA1 hash.

  Returns a SHA1 hash like `c8719790cdfff41c37c75e0c848d2b57535255aa`.

  ## Options

  The accepted options are:

  - `:case` - specifies the character case output

  The values for :case can be:
  - `:lower` - uses lower case characters (default)
  - `:upper` - uses upper case characters

  ## Examples

      iex> Nf.Hash.sha1()
      "c8719790cdfff41c37c75e0c848d2b57535255aa"

      iex> Nf.Hash.sha1(case: :upper)
      "C8719790CDFFF41C37C75E0C848D2B57535255AA"

  """
  @spec sha1(Keyword.t()) :: String.t()
  def sha1(options \\ []), do: generate_hash(:sha, options)

  @doc """
  Generate a random SHA256 hash.

  Returns a SHA256 hash like `d0ff021e810fb8f3442a14393604b0661b02f0dfcb347d80c9580af3ab5e7e6c`.

  ## Options

  The accepted options are:

  - `:case` - specifies the character case output

  The values for :case can be:
  - `:lower` - uses lower case characters (default)
  - `:upper` - uses upper case characters

  ## Examples

      iex> Nf.Hash.sha256()
      "d0ff021e810fb8f3442a14393604b0661b02f0dfcb347d80c9580af3ab5e7e6c"

      iex> Nf.Hash.sha256(case: :upper)
      "D0FF021E810FB8F3442A14393604B0661B02F0DFCB347D80C9580AF3AB5E7E6C"

  """
  @spec sha256(Keyword.t()) :: String.t()
  def sha256(options \\ []), do: generate_hash(:sha256, options)

  # Generate hash based on given hash type
  defp generate_hash(hash_type, options) do
    character_case =
      case Keyword.get(options, :case) do
        :upper -> :upper
        _ -> :lower
      end

    data = :crypto.strong_rand_bytes(16)

    hash_type |> :crypto.hash(data) |> Base.encode16(case: character_case)
  end
end
