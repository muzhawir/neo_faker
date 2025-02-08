defmodule Nf.Gravatar do
  @moduledoc """
  Functions for generating random Gravatar URLs based on email addresses.

  This module is based on the [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images).
  """
  @moduledoc since: "0.3.1"

  import Nf.Gravatar.Utils

  @typedoc "Email address"
  @type email :: String.t() | nil

  @doc """
  Creates a Gravatar URL based on the email address.

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

      iex> Nf.Gravatar.display()
      "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=identicon&s=80"

      iex> Nf.Gravatar.display("john.doe@example.com")
      "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=identicon&s=80"

      iex> Nf.Gravatar.display("john.doe@example.com", size: 100)
      "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=identicon&s=100"

      iex> Nf.Gravatar.display("john.doe@example.com", fallback: "monsterid")
      "https://gravatar.com/avatar/836f82db99121b3481011f16b49dfa5fbc714a0d1b1b9f784a1ebbbf5b39577f?d=monsterid&s=80"

  """
  @spec display(email(), Keyword.t()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    image_size = image_size(opts)
    default_fallback = default_fallback(opts)

    generate_gravatar_url(email, image_size, default_fallback)
  end
end
