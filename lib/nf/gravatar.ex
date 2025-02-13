defmodule Nf.Gravatar do
  @moduledoc """
  Provides functions for generating random Gravatar URLs.

  This module is based on the [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images).
  """
  @moduledoc since: "0.3.1"

  import Nf.Gravatar.Utils

  @typedoc "Email address"
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

  - `nil` (default) - Uses 80px.
  - `integer` - The image size in pixels (valid range: `1` to `2048`).

  The values for `:fallback` can be:

  - `nil` (default) - Uses `"identicon"`.
  - `:identicon` - Generates an "identicon".
  - `:monsterid` - Generates a "monsterid".
  - `:wavatar` - Generates a "wavatar".
  - `:robohash` - Generates a "robohash".

  ## Examples

      iex> Nf.Gravatar.display()
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> Nf.Gravatar.display("john.doe@example.com")
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> Nf.Gravatar.display("john.doe@example.com", size: 100)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=100"

      iex> Nf.Gravatar.display("john.doe@example.com", fallback: :monsterid)
      "https://gravatar.com/avatar/<hashed_email>?d=monsterid&s=80"

  """
  @spec display(email(), Keyword.t()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    image_size = image_size(size: opts[:size])
    default_fallback = default_fallback(fallback: opts[:fallback])

    generate_gravatar_url(email, image_size, default_fallback)
  end
end
