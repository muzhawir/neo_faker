defmodule NeoFaker.Gravatar.Validator do
  @moduledoc false

  @fallback_types [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]
  @min_size 1
  @max_size 2048

  @spec validate_size!(integer() | nil) :: :ok
  def validate_size!(nil), do: :ok

  def validate_size!(size) when is_integer(size) and size >= @min_size and size <= @max_size do
    :ok
  end

  def validate_size!(size) when is_integer(size) do
    raise ArgumentError, "Size must be between #{@min_size} and #{@max_size}, got: #{size}"
  end

  def validate_size!(size) do
    raise ArgumentError,
          "Size must be an integer between #{@min_size} and #{@max_size}, got: #{inspect(size)}"
  end

  @spec validate_and_format_fallback!(atom() | String.t()) :: String.t()
  def validate_and_format_fallback!(fallback) when is_atom(fallback) do
    if fallback in @fallback_types do
      Atom.to_string(fallback)
    else
      raise ArgumentError,
            "Invalid fallback type. Expected one of #{inspect(@fallback_types)} or a URL string, got: #{inspect(fallback)}"
    end
  end

  def validate_and_format_fallback!(fallback) when is_binary(fallback) do
    if String.starts_with?(fallback, ["http://", "https://"]) do
      fallback
    else
      raise ArgumentError,
            "Custom fallback URL must start with http:// or https://, got: #{inspect(fallback)}"
    end
  end

  def validate_and_format_fallback!(fallback) do
    raise ArgumentError,
          "Invalid fallback type. Expected atom or string, got: #{inspect(fallback)}"
  end

  @spec validate_rating!(atom() | nil) :: :ok
  def validate_rating!(nil), do: :ok

  def validate_rating!(rating) when rating in [:g, :pg, :r, :x], do: :ok

  def validate_rating!(rating) do
    raise ArgumentError,
          "Invalid rating. Expected one of [:g, :pg, :r, :x], got: #{inspect(rating)}"
  end

  @spec validate_profile_format!(atom()) :: :ok
  def validate_profile_format!(format) when format in [:html, :json, :xml, :php, :vcf, :qr] do
    :ok
  end

  def validate_profile_format!(format) do
    raise ArgumentError,
          "Invalid profile format. Expected one of [:html, :json, :xml, :php, :vcf, :qr], got: #{inspect(format)}"
  end
end
