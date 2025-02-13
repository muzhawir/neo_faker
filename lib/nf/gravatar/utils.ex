defmodule Nf.Gravatar.Utils do
  @moduledoc false

  @type email :: String.t() | nil

  @gravatar_url "https://gravatar.com/avatar/"
  @w3c_email_regex ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

  @doc """
  Extracts the image size from display options.

  Parses the given display options to determine the image size from 1 to 2048 pixel.
  If no valid size is specified, the default 80 pixel value is used.
  """
  @spec image_size(Keyword.t()) :: non_neg_integer()
  def image_size(size: nil), do: 80
  def image_size(size: size) when size in 1..2048, do: size

  @doc """
  Retrieves the default fallback image type from display options.

  Parses the given options to determine the fallback image type used when generating a Gravatar URL.
  """
  @spec default_fallback(Keyword.t()) :: String.t()
  def default_fallback(opts) when is_list(opts) do
    case Keyword.get(opts, :fallback, :identicon) do
      nil -> "identicon"
      :identicon -> "identicon"
      :monsterid -> "monsterid"
      :wavatar -> "wavatar"
      :robohash -> "robohash"
    end
  end

  @doc """
  Generates a Gravatar URL for the given email address.

  This function constructs a Gravatar URL using a hashed email, specified image size, and a
  fallback image type.
  """
  @spec generate_gravatar_url(email(), pos_integer(), String.t()) :: String.t()
  def generate_gravatar_url(email, image_size, default_fallback) do
    hashed_email =
      if is_nil(email) do
        random_email = "neo_faker_user_#{:rand.uniform(100_000)}@example.com"

        hash_email!(random_email)
      else
        hash_email!(email)
      end

    @gravatar_url
    |> URI.parse()
    |> URI.append_path("/#{hashed_email}")
    |> URI.append_query("d=#{default_fallback}")
    |> URI.append_query("s=#{image_size}")
    |> URI.to_string()
  end

  @doc """
  Hashes an email address into a Base16-encoded string.

  This function computes a cryptographic hash of the given email address and returns a Base16
  (hexadecimal) representation. If the input is invalid, an `ArgumentError` is raised.
  """
  @spec hash_email!(String.t()) :: String.t()
  def hash_email!(email) do
    if Regex.match?(@w3c_email_regex, email) do
      user_email = email |> String.trim() |> String.downcase()

      :sha256 |> :crypto.hash(user_email) |> Base.encode16(case: :lower)
    else
      raise ArgumentError, "Invalid email address"
    end
  end
end
