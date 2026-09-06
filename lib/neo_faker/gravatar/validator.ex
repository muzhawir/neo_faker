defmodule NeoFaker.Gravatar.Validator do
  @moduledoc false

  @fallback_types [:identicon, :monsterid, :wavatar, :robohash, :retro, :blank, :"404"]
  @min_size 1
  @max_size 2048

  @doc """
  Validates that the given size is either `nil` or an integer within the allowed range (1–2048).

  Returns `{:ok, size}` if valid, `{:error, message}` otherwise. Used as a `NimbleOptions`
  custom validator.
  """
  @spec validate_size(term()) :: {:ok, integer() | nil} | {:error, String.t()}
  def validate_size(nil), do: {:ok, nil}

  def validate_size(size) when is_integer(size) and size >= @min_size and size <= @max_size do
    {:ok, size}
  end

  def validate_size(size) when is_integer(size) do
    {:error, "Size must be between #{@min_size} and #{@max_size}, got: #{size}"}
  end

  def validate_size(size) do
    {:error,
     "Size must be an integer between #{@min_size} and #{@max_size}, got: #{inspect(size)}"}
  end

  @doc """
  Validates and formats the fallback image type for a Gravatar URL.

  Accepts either an atom from the known fallback types or a URL string starting with
  `http://` or `https://`. Returns `{:ok, fallback_as_string}` on success, `{:error,
  message}` otherwise. Used as a `NimbleOptions` custom validator.
  """
  @spec validate_and_format_fallback(term()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_and_format_fallback(fallback) when is_atom(fallback) do
    if fallback in @fallback_types do
      {:ok, Atom.to_string(fallback)}
    else
      {:error,
       "Invalid fallback type. Expected one of #{inspect(@fallback_types)} or a URL string, got: #{inspect(fallback)}"}
    end
  end

  def validate_and_format_fallback(fallback) when is_binary(fallback) do
    if String.starts_with?(fallback, ["http://", "https://"]) do
      {:ok, fallback}
    else
      {:error,
       "Custom fallback URL must start with http:// or https://, got: #{inspect(fallback)}"}
    end
  end

  def validate_and_format_fallback(fallback) do
    {:error, "Invalid fallback type. Expected atom or string, got: #{inspect(fallback)}"}
  end
end
