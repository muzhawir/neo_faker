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

  @display_schema NimbleOptions.new!(
                    size: [type: {:custom, Validator, :validate_size, []}, default: @size],
                    fallback: [
                      type: {:custom, Validator, :validate_and_format_fallback, []},
                      default: :identicon
                    ],
                    rating: [type: {:or, [nil, {:in, [:g, :pg, :r, :x]}]}, default: nil],
                    force_default: [type: :boolean, default: false]
                  )

  @profile_schema NimbleOptions.new!(
                    format: [
                      type: {:in, [:html, :json, :xml, :php, :vcf, :qr]},
                      default: :html
                    ]
                  )

  @doc """
  Generates a Gravatar image URL.

  Returns the Gravatar avatar URL for the given `email`. If `nil` is passed (the default),
  a random email is used instead.

  ## Options

    * `:size` (integer, `1`–`2048`) - the image size in pixels. Defaults to `80`.
    * `:fallback` (an atom below, or a custom `http://`/`https://` URL string) - the default
      image returned when no Gravatar is set for the email. Defaults to `:identicon`.
      * `:identicon` - a geometric pattern based on the email hash.
      * `:monsterid` - a generated monster image.
      * `:wavatar` - a generated face image.
      * `:robohash` - a generated robot image.
      * `:retro` - an 8-bit arcade-style pixelated face.
      * `:blank` - a transparent PNG.
      * `:"404"` - an HTTP 404 response instead of an image.
    * `:rating` (`:g`, `:pg`, `:r`, `:x`, or `nil`) - the maximum content rating to allow.
      Defaults to `nil` (no restriction).
      * `:g` - suitable for all audiences.
      * `:pg` - may contain mild profanity or suggestive content.
      * `:r` - may contain harsh profanity, violence, or nudity.
      * `:x` - may contain explicit sexual imagery or extreme violence.
    * `:force_default` (boolean) - when `true`, always returns the fallback image instead of
      the real Gravatar. Defaults to `false`.

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
  @spec display(email(), keyword()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    opts = Options.validate!(opts, @display_schema)

    validated_size = Generator.image_size(Keyword.fetch!(opts, :size))

    base_url = Generator.gravatar_url(email, validated_size, Keyword.fetch!(opts, :fallback))

    # Add optional parameters
    url_with_rating =
      if Keyword.fetch!(opts, :rating) do
        base_url <> "&r=#{Keyword.fetch!(opts, :rating)}"
      else
        base_url
      end

    if Keyword.fetch!(opts, :force_default) do
      url_with_rating <> "&f=y"
    else
      url_with_rating
    end
  end

  @doc """
  Generates a Gravatar profile URL.

  Returns the Gravatar profile page URL for the given `email`. If `nil` is passed (the
  default), a random email is used instead.

  ## Options

    * `:format` (`:html`, `:json`, `:xml`, `:php`, `:vcf`, or `:qr`) - the response format.
      Defaults to `:html`.
      * `:html` - the HTML profile page.
      * `:json` - the JSON API endpoint.
      * `:xml` - the XML API endpoint.
      * `:php` - the PHP serialized data endpoint.
      * `:vcf` - the vCard/VCF endpoint.
      * `:qr` - the QR code image endpoint.

  ## Examples

      iex> NeoFaker.Gravatar.profile()
      "https://gravatar.com/<hash>"

      iex> NeoFaker.Gravatar.profile("user@example.com", format: :json)
      "https://gravatar.com/<hash>.json"

      iex> NeoFaker.Gravatar.profile(nil, format: :xml)
      "https://gravatar.com/<hash>.xml"

  """
  @spec profile(email(), keyword()) :: String.t()
  def profile(email \\ nil, opts \\ []) do
    opts = Options.validate!(opts, @profile_schema)

    hash = Generator.email_hash(email)
    base_url = "https://gravatar.com/#{hash}"

    case Keyword.fetch!(opts, :format) do
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
