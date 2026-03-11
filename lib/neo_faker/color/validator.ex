defmodule NeoFaker.Color.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @color_formats [nil, :w3c]
  @hex_formats [:three_digit, :four_digit, :six_digit, :eight_digit]
  @color_keyword_categories [:all, :basic, :extended]

  @doc """
  Retrieves and validates the `:format` option from the given keyword list.

  Returns the format value if valid. Raises `ArgumentError` if the format is not one of
  `#{inspect([nil, :w3c])}`.
  """
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

  @doc """
  Validates the given HEX color format.

  Raises `ArgumentError` if the format is not one of `#{inspect([:three_digit, :four_digit, :six_digit, :eight_digit])}`.
  """
  @spec validate_hex_format!(atom()) :: :ok
  def validate_hex_format!(format) do
    case Options.validate_enum(:format, format, @hex_formats) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @doc """
  Validates the given color keyword category.

  Raises `ArgumentError` if the category is not one of `#{inspect([:all, :basic, :extended])}`.
  """
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
