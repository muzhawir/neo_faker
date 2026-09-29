defmodule NeoFaker.Gravatar.Validator do
  @moduledoc false

  @doc """
  NimbleOptions `{:custom, ...}` validator for the `:size` option.

  Accepts an integer in `range`; `nil` stands for `default`.
  """
  @spec validate_size(term(), Range.t(), pos_integer()) ::
          {:ok, pos_integer()} | {:error, String.t()}
  def validate_size(nil, _range, default), do: {:ok, default}

  def validate_size(size, range, _default) when is_integer(size) do
    if size in range do
      {:ok, size}
    else
      {:error, "expected an integer in #{inspect(range)}, got: #{size}"}
    end
  end

  def validate_size(size, range, _default) do
    {:error, "expected an integer in #{inspect(range)}, got: #{inspect(size)}"}
  end

  @doc """
  NimbleOptions `{:custom, ...}` validator for the `:fallback` option.

  Accepts one of `fallback_types` or an `http://`/`https://` URL, and returns it as
  the string that goes into the `d` query parameter.
  """
  @spec validate_fallback(term(), [atom()]) :: {:ok, String.t()} | {:error, String.t()}
  def validate_fallback(fallback, fallback_types) when is_atom(fallback) do
    if fallback in fallback_types do
      {:ok, Atom.to_string(fallback)}
    else
      {:error,
       "expected one of #{inspect(fallback_types)} or an http(s) URL, got: #{inspect(fallback)}"}
    end
  end

  def validate_fallback(fallback, _fallback_types) when is_binary(fallback) do
    case URI.new(fallback) do
      {:ok, %URI{scheme: scheme, host: host}}
      when scheme in ["http", "https"] and is_binary(host) and host != "" ->
        {:ok, fallback}

      _ ->
        {:error, "expected the fallback URL to be an http(s) URL, got: #{inspect(fallback)}"}
    end
  end

  def validate_fallback(fallback, fallback_types) do
    {:error,
     "expected one of #{inspect(fallback_types)} or an http(s) URL, got: #{inspect(fallback)}"}
  end
end
