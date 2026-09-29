defmodule NeoFaker.Color.Validator do
  @moduledoc false

  @doc """
  Returns `notation` if it is one of `notations`, raising `ArgumentError` otherwise.
  """
  @spec validate_notation!(term(), [atom(), ...]) :: atom()
  def validate_notation!(notation, notations) do
    if notation in notations do
      notation
    else
      raise ArgumentError,
            "invalid CSS notation #{inspect(notation)}, expected one of #{inspect(notations)}"
    end
  end
end
