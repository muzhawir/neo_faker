defmodule NeoFaker.Gravatar do
  @moduledoc """
  Functions for generating random Gravatar URLs.

  This module is based on the
  [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images).
  """
  @moduledoc since: "0.3.1"

  import NeoFaker.Gravatar.Util

  @typedoc "Email address."
  @type email :: String.t() | nil

  @doc """
  Generates a Gravatar image URL for the given email address with customizable size and fallback
  options.

  If no email is provided, a random email is used. The resulting URL includes query parameters
  for image size and fallback image type.

  ## Options

  The accepted options are:

  - `:size` - Defines the image size.
  - `:fallback` - Specifies the default fallback image.

  The values for `:size` can be:

  - `nil` - Uses `80px` (default).
  - `1` - `2048` - The image size in pixels (valid range: `1` to `2048`).

  The values for `:fallback` can be:

  - `:identicon` - Generates an "identicon" image (default).
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
    fallback = Keyword.get(opts, :fallback, :identicon)

    fallback_string =
      cond do
        is_atom(fallback) ->
          Atom.to_string(fallback)

        is_binary(fallback) ->
          fallback

        true ->
          raise ArgumentError,
                "invalid :fallback, expected atom or string, got: #{inspect(fallback)}"
      end

    generate_gravatar_url(
      email,
      image_size(Keyword.get(opts, :size)),
      fallback_string
    )
  end
end
