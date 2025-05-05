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
  Generates a Gravatar image URL for the given email address with customizable size and fallback options.
  
  If no email is provided, a random email is used. The resulting URL includes query parameters for image size (default: 80px) and fallback image type (default: identicon).
  
  ## Options
  
    - `:size` (integer): Image size in pixels (1–2048). Defaults to 80 if not specified.
    - `:fallback` (atom): Fallback image type if the email has no Gravatar. Supported values are `:identicon`, `:monsterid`, `:wavatar`, and `:robohash`. Defaults to `:identicon`.
  
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
    generate_gravatar_url(
      email,
      image_size(Keyword.get(opts, :size)),
      Atom.to_string(Keyword.get(opts, :fallback, :identicon))
    )
  end
end
