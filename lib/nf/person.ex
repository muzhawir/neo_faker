defmodule Nf.Person do

  alias Nf.Helper

  @typedoc "Random result in the form of a string or a list of strings"
  @type random_result :: String.t() | [String.t()]

  @module_name "gender"

  @doc """
  Returns a random non-binary gender.

  ## Examples

      iex> Nf.Gender.non_binary()
      "Agender"

  """
  @spec non_binary() :: random_result()
  def non_binary(amount \\ 1) when amount > 0 do
    list =
      @module_name
      |> Helper.read_locale_file("gender.exs")
      |> Map.get("non_binary")
      |> Enum.shuffle()

    cached_list =
      if :persistent_term.get(@module_name, nil) == nil do
        :persistent_term.put(@module_name, list)
        :persistent_term.get(@module_name)
      else
        :persistent_term.get(@module_name)
      end

    if amount == 1, do: Enum.random(cached_list), else: Enum.take(cached_list, amount)
  end
end
