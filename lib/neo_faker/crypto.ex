defmodule NeoFaker.Crypto do
  @moduledoc """
  Functions for generating cryptographic hashes and tokens.

  Provides utilities to generate random cryptographic values including MD5, SHA-1,
  SHA-256, SHA-512 hashes, UUID v4 identifiers, and secure random tokens.
  """
  @moduledoc since: "0.3.1"

  import Bitwise

  alias NeoFaker.Crypto.HashGenerator
  alias NeoFaker.Crypto.Validator
  alias NeoFaker.Helpers.Options

  @case_schema NimbleOptions.new!(case: [type: {:in, [:lower, :upper]}, default: :lower])

  @token_schema NimbleOptions.new!(encoding: [type: {:in, [:base64, :hex]}, default: :base64])

  @uuid_schema NimbleOptions.new!(
                 format: [type: {:in, [:standard, :compact]}, default: :standard],
                 case: [type: {:in, [:lower, :upper]}, default: :lower]
               )

  @doc """
  Generates a random MD5 hash.

  MD5 produces a 128-bit (32 hexadecimal character) hash value.

  ## Options

  - `:case` - Output character case. Either `:lower` (default) or `:upper`.

  ## Examples

      iex> NeoFaker.Crypto.md5()
      "afc4c626c55e4166421d82732163857d"

      iex> NeoFaker.Crypto.md5(case: :upper)
      "AFC4C626C55E4166421D82732163857D"

  """
  @spec md5(keyword()) :: String.t()
  def md5(opts \\ []) do
    opts = Options.validate!(opts, @case_schema)
    HashGenerator.generate_hash(:md5, opts)
  end

  @doc """
  Generates a random SHA-1 hash.

  SHA-1 produces a 160-bit (40 hexadecimal character) hash value.

  ## Options

  - `:case` - Output character case. Either `:lower` (default) or `:upper`.

  ## Examples

      iex> NeoFaker.Crypto.sha1()
      "356a192b7913b04c54574d18c28d46e6395428ab"

      iex> NeoFaker.Crypto.sha1(case: :upper)
      "356A192B7913B04C54574D18C28D46E6395428AB"

  """
  @spec sha1(keyword()) :: String.t()
  def sha1(opts \\ []) do
    opts = Options.validate!(opts, @case_schema)
    HashGenerator.generate_hash(:sha, opts)
  end

  @doc """
  Generates a random SHA-256 hash.

  SHA-256 produces a 256-bit (64 hexadecimal character) hash value.

  ## Options

  - `:case` - Output character case. Either `:lower` (default) or `:upper`.

  ## Examples

      iex> NeoFaker.Crypto.sha256()
      "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

      iex> NeoFaker.Crypto.sha256(case: :upper)
      "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  """
  @spec sha256(keyword()) :: String.t()
  def sha256(opts \\ []) do
    opts = Options.validate!(opts, @case_schema)
    HashGenerator.generate_hash(:sha256, opts)
  end

  @doc """
  Generates a random SHA-512 hash.

  SHA-512 produces a 512-bit (128 hexadecimal character) hash value.

  ## Options

  - `:case` - Output character case. Either `:lower` (default) or `:upper`.

  ## Examples

      iex> NeoFaker.Crypto.sha512()
      "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"

      iex> NeoFaker.Crypto.sha512(case: :upper)
      "CF83E1357EEFB8BDF1542850D66D8007D620E4050B5715DC83F4A921D36CE9CE47D0D13C5D85F2B0FF8318D2877EEC2F63B931BD47417A81A538327AF927DA3E"

  """
  @spec sha512(keyword()) :: String.t()
  def sha512(opts \\ []) do
    opts = Options.validate!(opts, @case_schema)
    HashGenerator.generate_hash(:sha512, opts)
  end

  @doc """
  Generates a random hash of the specified algorithm.

  A convenience dispatcher over `md5/1`, `sha1/1`, `sha256/1`, and `sha512/1`.

  ## Parameters

  - `type` - Hash algorithm. One of `:md5`, `:sha1`, `:sha256`, or `:sha512`.
  - `opts` - Keyword list of options:
    - `:case` - Output character case. Either `:lower` (default) or `:upper`.

  ## Examples

      iex> NeoFaker.Crypto.hash(:md5)
      "afc4c626c55e4166421d82732163857d"

      iex> NeoFaker.Crypto.hash(:sha256, case: :upper)
      "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  """
  @spec hash(atom(), keyword()) :: String.t()
  def hash(type, opts \\ []) do
    Validator.validate_hash_type!(type)
    opts = Options.validate!(opts, @case_schema)

    case type do
      :md5 -> HashGenerator.generate_hash(:md5, opts)
      :sha1 -> HashGenerator.generate_hash(:sha, opts)
      :sha256 -> HashGenerator.generate_hash(:sha256, opts)
      :sha512 -> HashGenerator.generate_hash(:sha512, opts)
    end
  end

  @doc """
  Generates a random secure token.

  Returns a URL-safe random token string suitable for API keys, session tokens,
  and similar secrets. The `length` controls the number of **random bytes** used,
  not the final string length (which varies by encoding).

  ## Parameters

  - `length` - Number of random bytes. Defaults to `32`.
  - `opts` - Keyword list of options:
    - `:encoding` - Output encoding. Either `:base64` (URL-safe, default) or `:hex`.

  ## Examples

      iex> NeoFaker.Crypto.token()
      "dGVzdF90b2tlbl9oZXJl"

      iex> NeoFaker.Crypto.token(32, encoding: :hex)
      "a1b2c3d4e5f6708192a3b4c5d6e7f8091a2b3c4d5e6f7081"

  """
  @spec token(pos_integer(), keyword()) :: String.t()
  def token(length \\ 32, opts \\ [])

  def token(length, opts) when is_integer(length) and length > 0 do
    opts = Options.validate!(opts, @token_schema)
    random_bytes = :crypto.strong_rand_bytes(length)

    case Keyword.fetch!(opts, :encoding) do
      :base64 -> Base.url_encode64(random_bytes, padding: false)
      :hex -> Base.encode16(random_bytes, case: :lower)
    end
  end

  def token(length, _opts) when is_integer(length) and length < 1 do
    raise ArgumentError, "length must be a positive integer, got: #{length}"
  end

  def token(length, _opts) do
    raise ArgumentError, "length must be a positive integer, got: #{inspect(length)}"
  end

  @doc """
  Generates a random UUID v4 string.

  ## Options

  - `:format` - Either `:standard` (dashes, default) or `:compact` (no dashes).
  - `:case` - Output character case. Either `:lower` (default) or `:upper`.

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
    opts = Options.validate!(opts, @uuid_schema)

    <<a::32, b::16, c::16, d::16, e::48>> = :crypto.strong_rand_bytes(16)

    # Set version 4 and variant bits
    uuid_string =
      case Keyword.fetch!(opts, :format) do
        :standard ->
          "~8.16.0b-~4.16.0b-4~3.16.0b-~4.16.0b-~12.16.0b"
          |> :io_lib.format([a, b, c &&& 0x0FFF, (d &&& 0x3FFF) ||| 0x8000, e])
          |> IO.iodata_to_binary()

        :compact ->
          "~8.16.0b~4.16.0b4~3.16.0b~4.16.0b~12.16.0b"
          |> :io_lib.format([a, b, c &&& 0x0FFF, (d &&& 0x3FFF) ||| 0x8000, e])
          |> IO.iodata_to_binary()
      end

    case Keyword.fetch!(opts, :case) do
      :lower -> String.downcase(uuid_string)
      :upper -> String.upcase(uuid_string)
    end
  end
end
