defmodule NeoFaker.Gravatar do
  @moduledoc """
  Provides functions for generating random Gravatar URLs.

  This module is based on the
  [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images).
  """
  @moduledoc since: "0.3.1"

  import NeoFaker.Gravatar.Util

  @typedoc "Email address."
  @type email :: String.t() | nil

  @doc """
  Generates a Gravatar URL from an email address.

  The generated URL includes query parameters for image size and fallback options.
  If no email address is provided, a random one is used.

  ## Options

  The accepted options are:

  - `:size` - Defines the image size.
  - `:fallback` - Specifies the default fallback image.

  The values for `:size` can be:

  - `nil` - Uses `80px` (default).
  - `1` - `2048` - The image size in pixels (valid range: `1` to `2048`).

  The values for `:fallback` can be:

  - `nil` - Generates an "identicon" image (default).
  - `:identicon` - Generates an "identicon" image.
  - `:monsterid` - Generates a "monsterid" image.
  - `:wavatar` - Generates a "wavatar" image.
  - `:robohash` - Generates a "robohash" image.

  ## Examples

      iex> NeoFaker.Gravatar.display()
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> NeoFaker.Gravatar.display("john.doe@example.com")
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", size: 100)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=100"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", fallback: :monsterid)
      "https://gravatar.com/avatar/<hashed_email>?d=monsterid&s=80"

  """
  @spec display(email(), Keyword.t()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    image_size = opts |> Keyword.get(:size) |> image_size()
    default_fallback = opts |> Keyword.get(:fallback) |> default_fallback()

    generate_gravatar_url(email, image_size, default_fallback)
  end
end
