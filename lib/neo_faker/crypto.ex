defmodule NeoFaker.Crypto do
  @moduledoc """
  Functions for generating hash digests, UUIDs, and random tokens.

  Hash functions return the digest of random input, so each call produces a
  realistic-looking but meaningless value. Hashes and UUIDs follow `NeoFaker.seed/1`;
  `token/2` does not, see its documentation.
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Crypto.Generator
  alias NeoFaker.Crypto.Validator

  @letter_cases [:lower, :upper]

  @case_schema NimbleOptions.new!(case: [type: {:in, @letter_cases}, default: :lower])

  @token_schema NimbleOptions.new!(encoding: [type: {:in, [:base64, :hex]}, default: :base64])

  @uuid_schema NimbleOptions.new!(
                 format: [type: {:in, [:standard, :compact]}, default: :standard],
                 case: [type: {:in, @letter_cases}, default: :lower]
               )

  @doc """
  Generates a random MD5 digest: 32 hexadecimal characters.

  ## Options

    * `:case` (`:lower` or `:upper`) - the case of the hex digits. Defaults to `:lower`.

  ## Examples

      iex> NeoFaker.Crypto.md5()
      "afc4c626c55e4166421d82732163857d"

      iex> NeoFaker.Crypto.md5(case: :upper)
      "AFC4C626C55E4166421D82732163857D"

  """
  @spec md5(keyword()) :: String.t()
  def md5(opts \\ []), do: hash(:md5, opts)

  @doc """
  Generates a random SHA-1 digest: 40 hexadecimal characters.

  ## Options

    * `:case` (`:lower` or `:upper`) - the case of the hex digits. Defaults to `:lower`.

  ## Examples

      iex> NeoFaker.Crypto.sha1()
      "356a192b7913b04c54574d18c28d46e6395428ab"

      iex> NeoFaker.Crypto.sha1(case: :upper)
      "356A192B7913B04C54574D18C28D46E6395428AB"

  """
  @spec sha1(keyword()) :: String.t()
  def sha1(opts \\ []), do: hash(:sha1, opts)

  @doc """
  Generates a random SHA-256 digest: 64 hexadecimal characters.

  ## Options

    * `:case` (`:lower` or `:upper`) - the case of the hex digits. Defaults to `:lower`.

  ## Examples

      iex> NeoFaker.Crypto.sha256()
      "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

      iex> NeoFaker.Crypto.sha256(case: :upper)
      "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  """
  @spec sha256(keyword()) :: String.t()
  def sha256(opts \\ []), do: hash(:sha256, opts)

  @doc """
  Generates a random SHA-512 digest: 128 hexadecimal characters.

  ## Options

    * `:case` (`:lower` or `:upper`) - the case of the hex digits. Defaults to `:lower`.

  ## Examples

      iex> NeoFaker.Crypto.sha512()
      "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"

  """
  @spec sha512(keyword()) :: String.t()
  def sha512(opts \\ []), do: hash(:sha512, opts)

  @doc """
  Generates a random digest for the hash algorithm `type`.

  `type` is one of `:md5`, `:sha1`, `:sha256`, or `:sha512`, and the result is the same
  as calling the function of that name. Raises `ArgumentError` for any other `type`.

  ## Options

    * `:case` (`:lower` or `:upper`) - the case of the hex digits. Defaults to `:lower`.

  ## Examples

      iex> NeoFaker.Crypto.hash(:md5)
      "afc4c626c55e4166421d82732163857d"

      iex> NeoFaker.Crypto.hash(:sha256, case: :upper)
      "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  """
  @spec hash(:md5 | :sha1 | :sha256 | :sha512, keyword()) :: String.t()
  def hash(type, opts \\ []) do
    Validator.validate_hash_type!(type)
    letter_case = opts |> NimbleOptions.validate!(@case_schema) |> Keyword.fetch!(:case)

    type |> crypto_algorithm() |> Generator.hash(letter_case)
  end

  @doc """
  Generates a random token from `length` cryptographically strong random bytes.

  `length` is the number of random bytes, not the length of the returned string, which
  depends on the encoding. It defaults to `32`.

  Unlike every other generator, this function reads `:crypto.strong_rand_bytes/1`, so its
  output is unpredictable and not affected by `NeoFaker.seed/1`.

  Raises `ArgumentError` if `length` is not a positive integer.

  ## Options

    * `:encoding` (`:base64` or `:hex`) - the output encoding. `:base64` is the URL-safe
      alphabet without padding; `:hex` is lowercase. Defaults to `:base64`.

  ## Examples

      iex> NeoFaker.Crypto.token()
      "Qm9zdG9uIGlzIHRoZSBjYXBpdGFsIG9mIE1hc3NhY2h1c2V0dHM"

      iex> NeoFaker.Crypto.token(8, encoding: :hex)
      "a1b2c3d4e5f60718"

  """
  @spec token(pos_integer(), keyword()) :: String.t()
  def token(length \\ 32, opts \\ [])

  def token(length, opts) when is_integer(length) and length > 0 do
    encoding = opts |> NimbleOptions.validate!(@token_schema) |> Keyword.fetch!(:encoding)
    bytes = :crypto.strong_rand_bytes(length)

    case encoding do
      :base64 -> Base.url_encode64(bytes, padding: false)
      :hex -> Base.encode16(bytes, case: :lower)
    end
  end

  def token(length, _opts) do
    raise ArgumentError, "length must be a positive integer, got: #{inspect(length)}"
  end

  @doc """
  Generates a random version 4 UUID.

  ## Options

    * `:format` (`:standard` or `:compact`) - `:standard` is the canonical 36-character
      form with dashes; `:compact` omits the dashes. Defaults to `:standard`.
    * `:case` (`:lower` or `:upper`) - the case of the hex digits. Defaults to `:lower`.

  ## Examples

      iex> NeoFaker.Crypto.uuid()
      "550e8400-e29b-41d4-a716-446655440000"

      iex> NeoFaker.Crypto.uuid(format: :compact)
      "550e8400e29b41d4a716446655440000"

      iex> NeoFaker.Crypto.uuid(case: :upper)
      "550E8400-E29B-41D4-A716-446655440000"

  """
  @spec uuid(keyword()) :: String.t()
  def uuid(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @uuid_schema)
    uuid = opts |> Keyword.fetch!(:case) |> Generator.uuid4()

    case Keyword.fetch!(opts, :format) do
      :standard -> Generator.dash_uuid(uuid)
      :compact -> uuid
    end
  end

  # `:crypto` names SHA-1 `:sha`.
  defp crypto_algorithm(:sha1), do: :sha
  defp crypto_algorithm(type), do: type
end
