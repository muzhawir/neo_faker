defmodule NeoFaker.Gravatar.Generator do
  @moduledoc false

  @base_url "https://gravatar.com/"

  # The WHATWG "valid email address" shape, anchored at both ends. It is
  # deliberately loose: Gravatar accepts anything email-shaped.
  @email_regex ~r/\A[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)+\z/

  @doc """
  Builds an avatar URL from an email hash and an ordered list of query parameters.
  Parameter values are percent-encoded, so a fallback URL cannot break the query.
  """
  @spec avatar_url(String.t(), keyword()) :: String.t()
  def avatar_url(hash, params), do: "#{@base_url}avatar/#{hash}?#{URI.encode_query(params)}"

  @doc """
  Builds a profile URL from an email hash, with an optional format extension.
  """
  @spec profile_url(String.t(), String.t() | nil) :: String.t()
  def profile_url(hash, nil), do: @base_url <> hash
  def profile_url(hash, extension), do: "#{@base_url}#{hash}.#{extension}"

  @doc """
  Returns the lowercase hex SHA-256 digest Gravatar uses to identify an email.

  The address is trimmed and downcased first, as Gravatar requires. `nil` hashes a
  random placeholder address, so repeated calls produce different avatars.

  Raises `ArgumentError` if `email` is not shaped like an email address.
  """
  @spec email_hash(String.t() | nil) :: String.t()
  def email_hash(nil), do: sha256("user#{:rand.uniform(1_000_000)}@example.com")

  def email_hash(email) when is_binary(email) do
    normalized = email |> String.trim() |> String.downcase()

    if Regex.match?(@email_regex, normalized) do
      sha256(normalized)
    else
      raise ArgumentError, "invalid email address #{inspect(email)}"
    end
  end

  def email_hash(email) do
    raise ArgumentError, "expected an email address string or nil, got: #{inspect(email)}"
  end

  defp sha256(string), do: :sha256 |> :crypto.hash(string) |> Base.encode16(case: :lower)
end
