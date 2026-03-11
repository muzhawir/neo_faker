defmodule NeoFaker.Gravatar do
  @moduledoc """
  Functions for generating random Gravatar URLs.

  Provides utilities to generate Gravatar image and profile URLs with customizable size,
  fallback type, rating, and format options, based on the
  [Gravatar API](https://docs.gravatar.com/api/avatars/images).
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Gravatar.Generator
  alias NeoFaker.Gravatar.Validator
  alias NeoFaker.Helpers.Options

  @typedoc "Email address."
  @type email :: String.t() | nil

  @fallback_types [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]
  @min_size 1
  @max_size 2048
  @size 80

  @doc """
  Generates a Gravatar image URL.

  Returns the Gravatar avatar URL for the given email address. If `nil` is passed,
  a random email is used.

  ## Parameters

  - `email` - Email address to hash. If `nil`, generates a random email.
  - `opts` - Keyword list of options:
    - `:size` - Image size in pixels (`1`–`2048`). Defaults to `80`.
    - `:fallback` - Default image type. Defaults to `:identicon`.
    - `:rating` - Maximum content rating. Defaults to `nil` (no restriction).
    - `:force_default` - When `true`, always returns the fallback image. Defaults to `false`.

  ## Options

  The values for `:fallback` can be:

  - `:identicon` - Geometric pattern based on email hash (default).
  - `:monsterid` - Generated monster image.
  - `:wavatar` - Generated face image.
  - `:robohash` - Generated robot image.
  - `:retro` - 8-bit arcade-style pixelated face.
  - `:blank` - Transparent PNG.
  - `:"404"` - HTTP 404 response.
  - Custom `http://` or `https://` URL string.

  The values for `:rating` can be:

  - `:g` - Suitable for all audiences.
  - `:pg` - May contain mild profanity or suggestive content.
  - `:r` - May contain harsh profanity, violence, or nudity.
  - `:x` - May contain explicit sexual imagery or extreme violence.

  ## Examples

      iex> NeoFaker.Gravatar.display()
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", size: 100)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=100"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", fallback: :monsterid)
      "https://gravatar.com/avatar/<hashed_email>?d=monsterid&s=80"

      iex> NeoFaker.Gravatar.display("user@test.com", rating: :pg)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80&r=pg"

      iex> NeoFaker.Gravatar.display("user@test.com", force_default: true)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80&f=y"

  """
  @spec display(email(), Keyword.t()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    size = Options.get(opts, :size, @size)
    fallback = Options.get(opts, :fallback, :identicon)
    rating = Options.get(opts, :rating, nil)
    force_default = Options.get(opts, :force_default, false)

    Validator.validate_size!(size)
    fallback_string = Validator.validate_and_format_fallback!(fallback)
    Validator.validate_rating!(rating)

    validated_size = Generator.image_size(size)

    base_url = Generator.gravatar_url(email, validated_size, fallback_string)

    # Add optional parameters
    url_with_rating =
      if rating do
        base_url <> "&r=#{rating}"
      else
        base_url
      end

    if force_default do
      url_with_rating <> "&f=y"
    else
      url_with_rating
    end
  end

  @doc """
  Generates a Gravatar profile URL.

  Returns the Gravatar profile page URL for the given email address. If `nil` is
  passed, a random email is used.

  ## Parameters

  - `email` - Email address to hash. If `nil`, generates a random email.
  - `opts` - Keyword list of options:
    - `:format` - Response format. Defaults to `:html`.

  ## Options

  The values for `:format` can be:

  - `:html` - HTML profile page (default).
  - `:json` - JSON API endpoint.
  - `:xml` - XML API endpoint.
  - `:php` - PHP serialized data endpoint.
  - `:vcf` - vCard/VCF endpoint.
  - `:qr` - QR code image endpoint.

  ## Examples

      iex> NeoFaker.Gravatar.profile()
      "https://gravatar.com/<hash>"

      iex> NeoFaker.Gravatar.profile("user@example.com", format: :json)
      "https://gravatar.com/<hash>.json"

      iex> NeoFaker.Gravatar.profile(nil, format: :xml)
      "https://gravatar.com/<hash>.xml"

  """
  @spec profile(email(), Keyword.t()) :: String.t()
  def profile(email \\ nil, opts \\ []) do
    format = Options.get(opts, :format, :html)
    Validator.validate_profile_format!(format)

    hash = Generator.email_hash(email)
    base_url = "https://gravatar.com/#{hash}"

    case format do
      :html -> base_url
      other -> "#{base_url}.#{other}"
    end
  end

  @doc """
  Generates a Gravatar image URL with randomly selected size and fallback type.

  ## Examples

      iex> NeoFaker.Gravatar.random()
      "https://gravatar.com/avatar/<hash>?d=monsterid&s=150"

      iex> NeoFaker.Gravatar.random()
      "https://gravatar.com/avatar/<hash>?d=wavatar&s=64"

  """
  @spec random() :: String.t()
  def random do
    random_size = Enum.random([@size, 100, 120, 150, 200, 256])
    random_fallback = Enum.random(@fallback_types)

    display(nil, size: random_size, fallback: random_fallback)
  end

  @doc """
  Returns the list of all valid fallback type atoms.

  ## Examples

      iex> NeoFaker.Gravatar.fallback_types()
      [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]

  """
  @spec fallback_types() :: [atom()]
  def fallback_types, do: @fallback_types

  @doc """
  Returns the default image size in pixels.

  ## Examples

      iex> NeoFaker.Gravatar.default_size()
      80

  """
  @spec default_size() :: pos_integer()
  def default_size, do: @size

  @doc """
  Returns the valid image size range.

  ## Examples

      iex> NeoFaker.Gravatar.size_range()
      1..2048

  """
  @spec size_range() :: Range.t()
  def size_range, do: @min_size..@max_size
end
