defmodule NeoFaker.Crypto.Generator do
  @moduledoc false

  # Hashes and UUIDs are built from `:rand.bytes/1`, not `:crypto`, so they
  # follow `NeoFaker.seed/1` like every other generator. They are fake data:
  # nothing about them needs to be unpredictable.

  @typedoc "An algorithm accepted by `:crypto.hash/2`."
  @type algorithm :: :md5 | :sha | :sha256 | :sha512

  @doc """
  Returns the hex-encoded digest of 16 random bytes under `algorithm`.
  """
  @spec hash(algorithm(), :lower | :upper) :: String.t()
  def hash(algorithm, letter_case) do
    algorithm
    |> :crypto.hash(:rand.bytes(16))
    |> Base.encode16(case: letter_case)
  end

  @doc """
  Returns a random version 4 UUID as a 32-character hex string, without dashes.

  RFC 9562 fixes 6 of the 128 bits: the version nibble is `0b0100` and the two
  variant bits are `0b10`. The remaining 122 bits are random.
  """
  @spec uuid4(:lower | :upper) :: String.t()
  def uuid4(letter_case) do
    <<a::48, _version::4, b::12, _variant::2, c::62>> = :rand.bytes(16)

    Base.encode16(<<a::48, 4::4, b::12, 2::2, c::62>>, case: letter_case)
  end

  @doc """
  Inserts the dashes of the canonical `8-4-4-4-12` UUID layout.
  """
  @spec dash_uuid(String.t()) :: String.t()
  def dash_uuid(<<a::binary-8, b::binary-4, c::binary-4, d::binary-4, e::binary-12>>) do
    Enum.join([a, b, c, d, e], "-")
  end
end
