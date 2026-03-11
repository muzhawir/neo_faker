defmodule NeoFaker.Lorem.Validator do
  @moduledoc false

  @text_sources [:lorem, :meditations]

  @spec validate_text_source!(atom()) :: :ok
  def validate_text_source!(source) when source in [:lorem, :meditations], do: :ok

  def validate_text_source!(source) do
    raise ArgumentError,
          "Invalid text source. Expected one of #{inspect(@text_sources)}, got: #{inspect(source)}"
  end
end
