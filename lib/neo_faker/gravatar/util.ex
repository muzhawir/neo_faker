defmodule NeoFaker.Gravatar.Util do
  @moduledoc false

  @typedoc "Email address."
  @type email :: String.t() | nil

  @gravatar_url "https://gravatar.com/avatar/"
  @w3c_email_regex ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

  @doc """
  Sets the image size for display options.

  Parses the given display options to determine the image size, which must be between `1` and
  `2048` pixels. If no valid size is specified, the default value of `80` pixels is used.
  """
  @spec image_size(non_neg_integer()) :: non_neg_integer()
  def image_size(size) when is_nil(size), do: 80
  def image_size(size) when size in 1..2048, do: size

  @doc """
  Generates a Gravatar URL for the given email address.

  Constructs a Gravatar URL using a hashed email, specified image size, and fallback image type.
  """
  @spec generate_gravatar_url(email(), pos_integer(), String.t()) :: String.t()
  def generate_gravatar_url(email, image_size, default_fallback) do
    @gravatar_url
    |> URI.parse()
    |> URI.append_path("/#{hash_email!(email)}")
    |> URI.append_query("d=#{default_fallback}")
    |> URI.append_query("s=#{image_size}")
    |> URI.to_string()
  end

  # Hashes an email address into a Base16-encoded string.
  @spec hash_email!(email()) :: String.t()
  defp hash_email!(email) when is_nil(email) do
    random_email = "neo_faker_user_#{:rand.uniform(100_000)}@example.com"

    :sha256 |> :crypto.hash(random_email) |> Base.encode16(case: :lower)
  end

  defp hash_email!(email) do
    if Regex.match?(@w3c_email_regex, email) do
      user_email = email |> String.trim() |> String.downcase()

      :sha256 |> :crypto.hash(user_email) |> Base.encode16(case: :lower)
    else
      raise ArgumentError, "Invalid email address"
    end
  end
end
