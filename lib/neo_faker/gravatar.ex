defmodule NeoFaker.Gravatar do
  @moduledoc """
  Functions for generating random Gravatar URLs.

  This module provides utilities to generate Gravatar image URLs with various customization
  options. It is based on the [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images).

  Gravatar (Globally Recognized Avatar) is a service for providing globally unique avatars
  based on email addresses.
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Gravatar.Generator
  alias NeoFaker.Helpers.Options

  @typedoc "Email address."
  @type email :: String.t() | nil

  @valid_fallback_types [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]
  @min_size 1
  @max_size 2048
  @default_size 80
  @default_fallback :identicon

  @doc """
  Generates a Gravatar image URL.

  Returns a string representing the Gravatar URL for the given email address. If an email is not
  provided, a random email is generated. The URL includes query parameters for image size and
  fallback image type.

  ## Parameters

  - `email` - The email address to generate a Gravatar for. If `nil`, generates a random email.
  - `opts` - Keyword list of options:
    - `:size` - Defines the image size in pixels. Defaults to `80`.
    - `:fallback` - Specifies the default fallback image. Defaults to `:identicon`.
    - `:rating` - Specifies the maximum rating. Defaults to `:g`.
    - `:force_default` - When `true`, always return the default image. Defaults to `false`.

  ## Options

  The values for `:size` can be:

  - `nil` - Uses `80px` (default).
  - `1` - `2048` - The image size in pixels (valid range: `1` to `2048`).

  The values for `:fallback` can be:

  - `:identicon` - Generates a geometric pattern based on email hash (default).
  - `:monsterid` - Generates a generated monster image.
  - `:wavatar` - Generates a generated face image.
  - `:robohash` - Generates a generated robot image.
  - `:retro` - Generates an 8-bit arcade-style pixelated face.
  - `:blank` - Returns a transparent PNG image.
  - `:"404"` - Returns an HTTP 404 (File Not Found) response.
  - Custom URL string - Uses a custom default image URL.

  The values for `:rating` can be:

  - `:g` - Suitable for display on all websites (default).
  - `:pg` - May contain rude gestures, provocatively dressed individuals, mild profanity.
  - `:r` - May contain harsh profanity, intense violence, nudity, or hard drug use.
  - `:x` - May contain hardcore sexual imagery or extremely disturbing violence.

  ## Examples

      iex> NeoFaker.Gravatar.display()
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> NeoFaker.Gravatar.display("john.doe@example.com")
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", size: 100)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=100"

      iex> NeoFaker.Gravatar.display("john.doe@example.com", fallback: :monsterid)
      "https://gravatar.com/avatar/<hashed_email>?d=monsterid&s=80"

      iex> NeoFaker.Gravatar.display(nil, size: 200, fallback: :robohash)
      "https://gravatar.com/avatar/<hashed_email>?d=robohash&s=200"

      iex> NeoFaker.Gravatar.display("user@test.com", rating: :pg)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80&r=pg"

      iex> NeoFaker.Gravatar.display("user@test.com", force_default: true)
      "https://gravatar.com/avatar/<hashed_email>?d=identicon&s=80&f=y"

  """
  @spec display(email(), Keyword.t()) :: String.t()
  def display(email \\ nil, opts \\ []) do
    size = Options.get(opts, :size, @default_size)
    fallback = Options.get(opts, :fallback, @default_fallback)
    rating = Options.get(opts, :rating, nil)
    force_default = Options.get(opts, :force_default, false)

    validate_size!(size)
    fallback_string = validate_and_format_fallback!(fallback)
    validate_rating!(rating)

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

  Returns a URL to the Gravatar profile page for the given email address.

  ## Parameters

  - `email` - The email address. If `nil`, generates a random email.
  - `opts` - Keyword list of options:
    - `:format` - The response format. Defaults to `:html`.

  ## Options

  The values for `:format` can be:

  - `:html` - Returns the HTML profile page URL (default).
  - `:json` - Returns the JSON API endpoint.
  - `:xml` - Returns the XML API endpoint.
  - `:php` - Returns the PHP serialized data endpoint.
  - `:vcf` - Returns the vCard/VCF endpoint.
  - `:qr` - Returns the QR code image endpoint.

  ## Examples

      iex> NeoFaker.Gravatar.profile()
      "https://gravatar.com/<hash>"

      iex> NeoFaker.Gravatar.profile("user@example.com")
      "https://gravatar.com/<hash>"

      iex> NeoFaker.Gravatar.profile("user@example.com", format: :json)
      "https://gravatar.com/<hash>.json"

      iex> NeoFaker.Gravatar.profile(nil, format: :xml)
      "https://gravatar.com/<hash>.xml"

  """
  @spec profile(email(), Keyword.t()) :: String.t()
  def profile(email \\ nil, opts \\ []) do
    format = Options.get(opts, :format, :html)
    validate_profile_format!(format)

    hash = Generator.email_hash(email)
    base_url = "https://gravatar.com/#{hash}"

    case format do
      :html -> base_url
      other -> "#{base_url}.#{other}"
    end
  end

  @doc """
  Generates a random Gravatar URL with random options.

  Returns a Gravatar URL with randomly selected size and fallback type.

  ## Examples

      iex> NeoFaker.Gravatar.random()
      "https://gravatar.com/avatar/<hash>?d=monsterid&s=150"

      iex> NeoFaker.Gravatar.random()
      "https://gravatar.com/avatar/<hash>?d=wavatar&s=64"

  """
  @spec random() :: String.t()
  def random do
    random_size = Enum.random([@default_size, 100, 120, 150, 200, 256])
    random_fallback = Enum.random(@valid_fallback_types)

    display(nil, size: random_size, fallback: random_fallback)
  end

  @doc """
  Returns a list of all valid fallback types.

  ## Examples

      iex> NeoFaker.Gravatar.fallback_types()
      [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]

  """
  @spec fallback_types() :: [atom()]
  def fallback_types, do: @valid_fallback_types

  @doc """
  Returns the default image size.

  ## Examples

      iex> NeoFaker.Gravatar.default_size()
      80

  """
  @spec default_size() :: pos_integer()
  def default_size, do: @default_size

  @doc """
  Returns the valid size range.

  ## Examples

      iex> NeoFaker.Gravatar.size_range()
      1..2048

  """
  @spec size_range() :: Range.t()
  def size_range, do: @min_size..@max_size

  # Private functions

  @spec validate_size!(integer() | nil) :: :ok
  defp validate_size!(nil), do: :ok

  defp validate_size!(size) when is_integer(size) and size >= @min_size and size <= @max_size do
    :ok
  end

  defp validate_size!(size) when is_integer(size) do
    raise ArgumentError, "Size must be between #{@min_size} and #{@max_size}, got: #{size}"
  end

  defp validate_size!(size) do
    raise ArgumentError,
          "Size must be an integer between #{@min_size} and #{@max_size}, got: #{inspect(size)}"
  end

  @spec validate_and_format_fallback!(atom() | String.t()) :: String.t()
  defp validate_and_format_fallback!(fallback) when is_atom(fallback) do
    if fallback in @valid_fallback_types do
      Atom.to_string(fallback)
    else
      raise ArgumentError,
            "Invalid fallback type. Expected one of #{inspect(@valid_fallback_types)} or a URL string, got: #{inspect(fallback)}"
    end
  end

  defp validate_and_format_fallback!(fallback) when is_binary(fallback) do
    # Custom URL - validate it's a reasonable URL format
    if String.starts_with?(fallback, ["http://", "https://"]) do
      fallback
    else
      raise ArgumentError,
            "Custom fallback URL must start with http:// or https://, got: #{inspect(fallback)}"
    end
  end

  defp validate_and_format_fallback!(fallback) do
    raise ArgumentError,
          "Invalid fallback type. Expected atom or string, got: #{inspect(fallback)}"
  end

  @spec validate_rating!(atom() | nil) :: :ok
  defp validate_rating!(nil), do: :ok

  defp validate_rating!(rating) when rating in [:g, :pg, :r, :x], do: :ok

  defp validate_rating!(rating) do
    raise ArgumentError,
          "Invalid rating. Expected one of [:g, :pg, :r, :x], got: #{inspect(rating)}"
  end

  @spec validate_profile_format!(atom()) :: :ok
  defp validate_profile_format!(format) when format in [:html, :json, :xml, :php, :vcf, :qr] do
    :ok
  end

  defp validate_profile_format!(format) do
    raise ArgumentError,
          "Invalid profile format. Expected one of [:html, :json, :xml, :php, :vcf, :qr], got: #{inspect(format)}"
  end
end
