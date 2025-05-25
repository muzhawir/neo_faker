defmodule NeoFaker.Gravatar.Util do
  @moduledoc false

  @typedoc "Email address."
  @type email :: String.t() | nil

  @gravatar_url "https://gravatar.com/avatar/"
  @w3c_email_regex ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

  @doc """
  Returns the Gravatar image size, defaulting to 80 if the input is `nil`.

  If a size is provided, it is returned as-is. The expected valid range is 1 to 2048 pixels.
  """
  @spec image_size(integer() | nil) :: integer()
  def image_size(nil), do: 80
  def image_size(size) when size in 1..2048, do: size

  @doc """
  Generates a Gravatar URL for the specified email, image size, and fallback image type.

  The email is hashed and incorporated into the URL path, with query parameters for the fallback
  image and size.
  """
  @spec generate_gravatar_url(email(), integer(), String.t()) :: String.t()
  def generate_gravatar_url(email, image_size, default_fallback) do
    email_hash = hash_email!(email)

    @gravatar_url
    |> URI.parse()
    |> URI.append_path("/#{email_hash}")
    |> URI.append_query("d=#{default_fallback}")
    |> URI.append_query("s=#{image_size}")
    |> URI.to_string()
  end

  defp hash_email!(nil) do
    random_email = "neo_faker_user_#{:rand.uniform(100_000)}@example.com"

    hash_string(random_email)
  end

  defp hash_email!(email) when is_binary(email) do
    if Regex.match?(@w3c_email_regex, email) do
      email
      |> String.trim()
      |> String.downcase()
      |> hash_string()
    else
      raise ArgumentError, "Invalid email address"
    end
  end

  defp hash_string(str) do
    :sha256 |> :crypto.hash(str) |> Base.encode16(case: :lower)
  end
end
