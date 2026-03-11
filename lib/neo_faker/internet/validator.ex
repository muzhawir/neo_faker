defmodule NeoFaker.Internet.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @username_joiners [:all, :dot, :underscore, :dash]
  @username_types [:person, :word]
  @domain_types [:random, :popular, :custom]
  @popular_domain_types [:all, :ecommerce, :email, :search, :social]
  @tld_types [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]

  @doc """
  Validates the username joiner option.

  Raises `ArgumentError` if the joiner is not one of `#{inspect(@username_joiners)}`.
  """
  @spec validate_username_joiner!(atom()) :: :ok
  def validate_username_joiner!(joiner) do
    case Options.validate_enum(:joiner, joiner, @username_joiners) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the username type option.

  Raises `ArgumentError` if the type is not one of `#{inspect(@username_types)}`.
  """
  @spec validate_username_type!(atom()) :: :ok
  def validate_username_type!(type) do
    case Options.validate_enum(:username_type, type, @username_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the domain type option.

  Raises `ArgumentError` if the type is not one of `#{inspect(@domain_types)}`.
  """
  @spec validate_domain_type!(atom()) :: :ok
  def validate_domain_type!(type) do
    case Options.validate_enum(:type, type, @domain_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the popular domain type option.

  Raises `ArgumentError` if the type is not one of `#{inspect(@popular_domain_types)}`.
  """
  @spec validate_popular_domain_type!(atom()) :: :ok
  def validate_popular_domain_type!(type) do
    case Options.validate_enum(:popular_type, type, @popular_domain_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the TLD type option.

  Raises `ArgumentError` if the type is not one of `#{inspect(@tld_types)}`.
  """
  @spec validate_tld_type!(atom()) :: :ok
  def validate_tld_type!(type) do
    case Options.validate_enum(:type, type, @tld_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates that the word count is a positive integer.

  Raises `ArgumentError` if `count` is not a positive integer.
  """
  @spec validate_word_count!(pos_integer()) :: :ok
  def validate_word_count!(count) when is_integer(count) and count > 0, do: :ok

  def validate_word_count!(count) when is_integer(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{count}"
  end

  def validate_word_count!(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{inspect(count)}"
  end

  @doc """
  Validates the MAC address separator.

  Raises `ArgumentError` if `sep` is not one of `":"`, `"-"`, or `""`.
  """
  @spec validate_mac_separator!(String.t()) :: :ok
  def validate_mac_separator!(sep) when sep in [":", "-", ""], do: :ok

  def validate_mac_separator!(sep) do
    raise ArgumentError,
          "Invalid MAC separator. Expected one of [\":\", \"-\", \"\"], got: #{inspect(sep)}"
  end

  @doc """
  Validates the URL protocol option.

  Raises `ArgumentError` if the protocol is not one of `[:http, :https]`.
  """
  @spec validate_protocol!(atom()) :: :ok
  def validate_protocol!(protocol) when protocol in [:http, :https], do: :ok

  def validate_protocol!(protocol) do
    raise ArgumentError,
          "Invalid protocol. Expected one of [:http, :https], got: #{inspect(protocol)}"
  end
end
