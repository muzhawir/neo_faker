defmodule NeoFaker.Lorem.Validator do
  @moduledoc false

  @text_sources [:lorem, :meditations]

  @doc """
  Validates that the given text source is one of the supported sources.

  Raises `ArgumentError` if the source is not `:lorem` or `:meditations`.
  """
  @spec validate_text_source!(atom()) :: :ok
  def validate_text_source!(source) when source in [:lorem, :meditations], do: :ok

  def validate_text_source!(source) do
    raise ArgumentError,
          "Invalid text source. Expected one of #{inspect(@text_sources)}, got: #{inspect(source)}"
  end
end
