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
  Returns the validated `opts`, raising `NimbleOptions.ValidationError` if the
  caller passed `key` in `raw_opts` while `required_key` is not `true`.

  NimbleOptions validates each key on its own, so an option that only has an
  effect together with another one would otherwise be ignored without an error.
  `raw_opts` are the options as given, so a schema default never triggers this.
  Meant to follow `NimbleOptions.validate!/2` in a pipeline.
  """
  @spec validate_requires!(keyword(), keyword(), atom(), atom()) :: keyword()
  def validate_requires!(opts, raw_opts, key, required_key) do
    value = Keyword.get(raw_opts, key)

    if is_nil(value) or Keyword.fetch!(opts, required_key) do
      opts
    else
      raise NimbleOptions.ValidationError,
        key: key,
        value: value,
        message: "option #{inspect(key)} requires #{required_key}: true, got: #{inspect(value)}"
    end
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
