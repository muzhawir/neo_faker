defmodule NeoFaker.Color.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @color_formats [nil, :w3c]
  @hex_formats [:three_digit, :four_digit, :six_digit, :eight_digit]
  @color_keyword_categories [:all, :basic, :extended]

  @spec get_and_validate_color_format!(Keyword.t()) :: atom() | nil
  def get_and_validate_color_format!(opts) do
    format = Options.get(opts, :format, nil)

    case Options.validate_enum(:format, format, @color_formats) do
      :ok ->
        format

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_hex_format!(atom()) :: :ok
  def validate_hex_format!(format) do
    case Options.validate_enum(:format, format, @hex_formats) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_color_category!(atom()) :: :ok
  def validate_color_category!(category) do
    case Options.validate_enum(:category, category, @color_keyword_categories) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
