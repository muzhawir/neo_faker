defmodule NeoFaker.Gravatar do
  @moduledoc """
  Functions for generating Gravatar avatar and profile URLs.

  URLs follow the [Gravatar image requests](https://docs.gravatar.com/api/avatars/images/)
  format and identify the email by its SHA-256 hash. Every function takes an optional
  email address; without one, a random address is hashed instead.
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Gravatar.Generator
  alias NeoFaker.Gravatar.Validator

  @fallback_types [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]
  @ratings [:g, :pg, :r, :x]
  @profile_formats [:html, :json, :xml, :php, :vcf, :qr]
  @size_range 1..2048
  @default_size 80
  @random_sizes [@default_size, 100, 120, 150, 200, 256]

  @display_schema NimbleOptions.new!(
                    size: [
                      type: {:custom, Validator, :validate_size, [@size_range, @default_size]},
                      default: @default_size
                    ],
                    fallback: [
                      type: {:custom, Validator, :validate_fallback, [@fallback_types]},
                      default: :identicon
                    ],
                    rating: [type: {:in, [nil | @ratings]}, default: nil],
                    force_default: [type: :boolean, default: false]
                  )

  @profile_schema NimbleOptions.new!(format: [type: {:in, @profile_formats}, default: :html])

  @typedoc "An email address, or `nil` for a random one."
  @type email :: String.t() | nil

  @doc """
  Generates a Gravatar avatar image URL for `email`.

  When `email` is `nil`, the default, a random address is used. Raises `ArgumentError`
  if `email` is not shaped like an email address.

  ## Options

    * `:size` (integer from `1` to `2048`) - the image size in pixels. Defaults to `80`.
    * `:fallback` (an atom below, or an `http://` or `https://` URL) - the image returned
      when the email has no Gravatar. Defaults to `:identicon`.
      * `:identicon` - a geometric pattern based on the email hash.
      * `:monsterid` - a generated monster.
      * `:wavatar` - a generated face.
      * `:robohash` - a generated robot.
      * `:retro` - an 8-bit arcade-style face.
      * `:blank` - a transparent PNG.
      * `:"404"` - no image; Gravatar responds with HTTP 404.
    * `:rating` (`:g`, `:pg`, `:r`, `:x`, or `nil`) - the highest content rating to
      allow. Defaults to `nil`, which leaves Gravatar's own default (`:g`) in place.
    * `:force_default` (boolean) - when `true`, always returns the fallback image, even
      if the email has a Gravatar. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Gravatar.display()
      "https://gravatar.com/avatar/<hash>?d=identicon&s=80"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", size: 100)
      "https://gravatar.com/avatar/<hash>?d=identicon&s=100"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", fallback: :monsterid, rating: :pg)
      "https://gravatar.com/avatar/<hash>?d=monsterid&s=80&r=pg"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", fallback: "https://example.com/a.png")
      "https://gravatar.com/avatar/<hash>?d=https%3A%2F%2Fexample.com%2Fa.png&s=80"

  """
  @spec display(email(), keyword()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @display_schema)

    params =
      Enum.reject(
        [
          d: Keyword.fetch!(opts, :fallback),
          s: Keyword.fetch!(opts, :size),
          r: Keyword.fetch!(opts, :rating),
          f: if(Keyword.fetch!(opts, :force_default), do: "y")
        ],
        fn {_key, value} -> is_nil(value) end
      )

    email |> Generator.email_hash() |> Generator.avatar_url(params)
  end

  @doc """
  Generates a Gravatar profile URL for `email`.

  When `email` is `nil`, the default, a random address is used. Raises `ArgumentError`
  if `email` is not shaped like an email address.

  ## Options

    * `:format` - the profile representation to link to. Defaults to `:html`.
      * `:html` - the profile web page.
      * `:json`, `:xml`, `:php` - profile data in that format.
      * `:vcf` - a vCard.
      * `:qr` - a QR code image linking to the profile.

  ## Examples

      iex> NeoFaker.Gravatar.profile()
      "https://gravatar.com/<hash>"

      iex> NeoFaker.Gravatar.profile("user@example.com", format: :json)
      "https://gravatar.com/<hash>.json"

  """
  @spec profile(email(), keyword()) :: String.t()
  def profile(email \\ nil, opts \\ []) do
    extension =
      case opts |> NimbleOptions.validate!(@profile_schema) |> Keyword.fetch!(:format) do
        :html -> nil
        format -> Atom.to_string(format)
      end

    email |> Generator.email_hash() |> Generator.profile_url(extension)
  end

  @doc """
  Generates an avatar URL for a random email, with a random size and fallback image.

  ## Examples

      iex> NeoFaker.Gravatar.random_display()
      "https://gravatar.com/avatar/<hash>?d=monsterid&s=150"

  """
  @doc since: "0.15.0"
  @spec random_display() :: String.t()
  def random_display do
    display(nil, size: Enum.random(@random_sizes), fallback: Enum.random(@fallback_types))
  end

  @doc """
  Returns the fallback image types accepted by the `:fallback` option of `display/2`.

  ## Examples

      iex> NeoFaker.Gravatar.fallback_types()
      [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]

  """
  @spec fallback_types() :: [atom(), ...]
  def fallback_types, do: @fallback_types

  @doc """
  Returns the default image size, in pixels.

  ## Examples

      iex> NeoFaker.Gravatar.default_size()
      80

  """
  @spec default_size() :: pos_integer()
  def default_size, do: @default_size

  @doc """
  Returns the range of image sizes accepted by the `:size` option of `display/2`.

  ## Examples

      iex> NeoFaker.Gravatar.size_range()
      1..2048

  """
  @spec size_range() :: Range.t()
  def size_range, do: @size_range
end
