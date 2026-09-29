defmodule NeoFaker.Internet.Validator do
  @moduledoc false

  @doc """
  NimbleOptions `{:custom, ...}` validator for the `:domain_name` option: any non-empty
  string. The value is returned verbatim, so it is not checked against DNS syntax.
  """
  @spec validate_domain_name(term()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_domain_name(domain) when is_binary(domain) and domain != "", do: {:ok, domain}

  def validate_domain_name(domain) do
    {:error, "expected a non-empty string such as \"example.com\", got: #{inspect(domain)}"}
  end

  @doc """
  Returns `count` if it is a positive integer, raising `ArgumentError` otherwise.
  """
  @spec validate_word_count!(term()) :: pos_integer()
  def validate_word_count!(count) when is_integer(count) and count > 0, do: count

  def validate_word_count!(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{inspect(count)}"
  end
end
