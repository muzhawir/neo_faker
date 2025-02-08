defmodule Nf.Gravatar.Utils do
  @moduledoc false
  @moduledoc since: "0.3.1"

  import URI, only: [parse: 1, append_path: 2, append_query: 2]

  @type email :: String.t() | nil
  @type gravatar_url :: String.t() | ArgumentError
  @type hashed_email :: String.t() | ArgumentError

  @gravatar_url "https://gravatar.com/avatar/"
  @w3c_email_regex ~r/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

  @doc """
  Hash email address to base16 string.

  Returns a base16 string or raises an `ArgumentError`.
  """
  @spec hash_email!(String.t()) :: hashed_email()
  def hash_email!(email) do
    if Regex.match?(@w3c_email_regex, email) do
      user_email = email |> String.trim() |> String.downcase()

      :sha256 |> :crypto.hash(user_email) |> Base.encode16(case: :lower)
    else
      raise ArgumentError, "Invalid email address"
    end
  end

  @doc """
  Get image size from display opts.

  Returns an image size between 1 and 2048 pixels.
  """
  @spec image_size(Keyword.t()) :: integer()
  def image_size(opts) when is_list(opts) do
    case Keyword.get(opts, :size, 80) do
      nil -> 80
      size when size in 1..2048 -> size
    end
  end

  @doc """
  Get default fallback from display options.

  Returns a default fallback image type.
  """
  @spec default_fallback(Keyword.t()) :: String.t()
  def default_fallback(opts) when is_list(opts) do
    case Keyword.get(opts, :fallback, "identicon") do
      nil -> "identicon"
      "identicon" -> "identicon"
      "monsterid" -> "monsterid"
      "wavatar" -> "wavatar"
      "robohash" -> "robohash"
    end
  end

  @doc """
  Generate Gravatar URL.

  Returns a Gravatar URL with image size and default fallback query parameters.
  """
  @spec generate_gravatar_url(email(), pos_integer(), String.t()) :: gravatar_url()
  def generate_gravatar_url(email, image_size, default_fallback) do
    hashed_email =
      if is_nil(email) do
        random_email = "neo_faker_user_#{:rand.uniform(100_000)}@example.com"

        hash_email!(random_email)
      else
        hash_email!(email)
      end

    @gravatar_url
    |> parse()
    |> append_path("/#{hashed_email}")
    |> append_query("d=#{default_fallback}")
    |> append_query("s=#{image_size}")
    |> URI.to_string()
  end
end
