defmodule NeoFaker.Internet.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @username_joiners [:all, :dot, :underscore, :dash]
  @username_types [:person, :word]
  @domain_types [:random, :popular, :custom]
  @popular_domain_types [:all, :ecommerce, :email, :search, :social]
  @tld_types [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]

  @spec validate_username_joiner!(atom()) :: :ok
  def validate_username_joiner!(joiner) do
    case Options.validate_enum(:joiner, joiner, @username_joiners) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_username_type!(atom()) :: :ok
  def validate_username_type!(type) do
    case Options.validate_enum(:username_type, type, @username_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_domain_type!(atom()) :: :ok
  def validate_domain_type!(type) do
    case Options.validate_enum(:type, type, @domain_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_popular_domain_type!(atom()) :: :ok
  def validate_popular_domain_type!(type) do
    case Options.validate_enum(:popular_type, type, @popular_domain_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_tld_type!(atom()) :: :ok
  def validate_tld_type!(type) do
    case Options.validate_enum(:type, type, @tld_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_word_count!(pos_integer()) :: :ok
  def validate_word_count!(count) when is_integer(count) and count > 0, do: :ok

  def validate_word_count!(count) when is_integer(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{count}"
  end

  def validate_word_count!(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{inspect(count)}"
  end

  @spec validate_mac_separator!(String.t()) :: :ok
  def validate_mac_separator!(sep) when sep in [":", "-", ""], do: :ok

  def validate_mac_separator!(sep) do
    raise ArgumentError,
          "Invalid MAC separator. Expected one of [\":\", \"-\", \"\"], got: #{inspect(sep)}"
  end

  @spec validate_protocol!(atom()) :: :ok
  def validate_protocol!(protocol) when protocol in [:http, :https], do: :ok

  def validate_protocol!(protocol) do
    raise ArgumentError,
          "Invalid protocol. Expected one of [:http, :https], got: #{inspect(protocol)}"
  end
end
