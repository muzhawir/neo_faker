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
  def image_size(size) when is_nil(size), do: 80
  def image_size(size) when size in 1..2048, do: size

  @doc """
  Generates a Gravatar URL for the specified email, image size, and fallback image type.

  The email is hashed and incorporated into the URL path, with query parameters for the fallback
  image and size.
  """
  @spec generate_gravatar_url(email(), integer(), String.t()) :: String.t()
  def generate_gravatar_url(email, image_size, default_fallback) do
    @gravatar_url
    |> URI.parse()
    |> URI.append_path("/#{hash_email!(email)}")
    |> URI.append_query("d=#{default_fallback}")
    |> URI.append_query("s=#{image_size}")
    |> URI.to_string()
  end

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
