defmodule NeoFaker.Gravatar.Generator do
  @moduledoc false

  @typedoc "Email address."
  @type email :: String.t() | nil

  @gravatar_url "https://gravatar.com/avatar/"
  # The HTML5/WHATWG "valid email address" pattern (the same one browsers use for
  # <input type="email">). Deliberately permissive, not full RFC 5322 validation,
  # since Gravatar itself accepts anything email-shaped.
  @w3c_email_regex ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  @default_image_size 80

  @doc """
  Returns `size`, or the default when `size` is `nil`. Does not itself enforce the 1..2048
  range; callers validate that separately before calling this.
  """
  @spec image_size(integer() | nil) :: integer()
  def image_size(nil), do: @default_image_size
  def image_size(size) when size in 1..2048, do: size

  @doc """
  Builds the Gravatar image URL from an email hash, size, and fallback type.
  """
  @spec gravatar_url(email(), integer(), String.t()) :: String.t()
  def gravatar_url(email, image_size, default_fallback) do
    @gravatar_url
    |> URI.parse()
    |> URI.append_path("/#{email_hash(email)}")
    |> URI.append_query("d=#{default_fallback}")
    |> URI.append_query("s=#{image_size}")
    |> URI.to_string()
  end

  @doc """
  Hashes an email address for use in a Gravatar URL.

  When `email` is `nil`, hashes a freshly randomized placeholder address instead of a fixed
  constant, so repeated calls with no email don't all collapse to the same Gravatar hash (and
  therefore the same avatar).
  """
  @spec email_hash(email()) :: String.t()
  def email_hash(nil) do
    random_email = "neo_faker_user_#{:rand.uniform(100_000)}@example.com"
    hash_string(random_email)
  end

  def email_hash(email) when is_binary(email) do
    if Regex.match?(@w3c_email_regex, email) do
      email |> String.trim() |> String.downcase() |> hash_string()
    else
      raise ArgumentError, "Invalid email address"
    end
  end

  defp hash_string(str) do
    :sha256 |> :crypto.hash(str) |> Base.encode16(case: :lower)
  end
end
