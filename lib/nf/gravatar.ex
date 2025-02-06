defmodule NF.Gravatar do
  @moduledoc """
  Functions for generate a random Gravatar URL based on an email address.

  This module is based on the [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images).
  """

  import URI, only: [parse: 1, append_path: 2, append_query: 2]

  @typedoc "Email address"
  @type email() :: String.t() | nil

  @gravatar_url "https://gravatar.com/avatar/"

  @doc """
  Generate a Gravatar URL based on an email address.

  Returns a Gravatar URL with image size and default fallback query parameters.

  ## Options

  The accepted options are:

  - `:size` - specifies the image size
  - `:fallback` - specifies the default fallback image

  The values for `:size` can be:
  - `nil` - uses 80px (default)
  - `integer` - specifies the image size in pixels from 1 to 2048

  The values for `:fallback` can be:
  - `nil` - uses "identicon" (default)
  - `"identicon"` - uses "identicon"
  - `"monsterid"` - uses "monsterid"
  - `"wavatar"` - uses "wavatar"
  - `"robohash"` - uses "robohash"

  ## Examples

      iex> NF.Gravatar.display()
      "https://gravatar.com/avatar/205dd4220590dff2992f6146560666b5372d5acec005577fee792357ef3533dc?d=identicon&s=80"

      iex> NF.Gravatar.display("example.com")
      "https://gravatar.com/avatar/a379a6f6eeafb9a55e378c118034e2751e682fab9f2d30ab13d2125586ce1947?d=identicon&s=80"

      iex> NF.Gravatar.display("example.com", size: 100)
      "https://gravatar.com/avatar/a379a6f6eeafb9a55e378c118034e2751e682fab9f2d30ab13d2125586ce1947?d=identicon&s=100"

      iex> NF.Gravatar.display("example.com", fallback: "monsterid")
      "https://gravatar.com/avatar/a379a6f6eeafb9a55e378c118034e2751e682fab9f2d30ab13d2125586ce1947?d=monsterid&s=80"

  """
  @spec display(email(), Keyword.t()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    image_size = image_size(opts)
    default_fallback = default_fallback(opts)

    generate_gravatar_url(email, image_size, default_fallback)
  end

  # Hash email using SHA256
  defp hash_email(email) do
    user_email = email |> String.trim() |> String.downcase()

    :sha256 |> :crypto.hash(user_email) |> Base.encode16(case: :lower)
  end

  # Get image size from display options
  defp image_size(opts) when is_list(opts) do
    case Keyword.get(opts, :size, 80) do
      nil -> 80
      size when is_integer(size) -> size
    end
  end

  # Get default fallback from display options
  defp default_fallback(opts) when is_list(opts) do
    case Keyword.get(opts, :fallback, "identicon") do
      nil -> "identicon"
      "identicon" -> "identicon"
      "monsterid" -> "monsterid"
      "wavatar" -> "wavatar"
      "robohash" -> "robohash"
    end
  end

  # Generate Gravatar URL with image size and default fallback query parameters
  defp generate_gravatar_url(email, image_size, default_fallback) do
    hashed_email =
      case email do
        nil -> hash_email("example_#{:rand.uniform(10_000)}.com")
        _ -> hash_email(email)
      end

    @gravatar_url
    |> parse()
    |> append_path("/#{hashed_email}")
    |> append_query("d=#{default_fallback}")
    |> append_query("s=#{image_size}")
    |> URI.to_string()
  end
end
