defmodule NeoFaker.Blood.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @formats [:group, :type_only, :rh_only]

  @spec validate_format!(atom()) :: :ok
  def validate_format!(format) do
    case Options.validate_enum(:format, format, @formats) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
