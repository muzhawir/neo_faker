defmodule NeoFaker.Helpers.Formatter do
  @moduledoc false

  # String-shaping helpers shared by several domain modules.

  @doc """
  Upcases or downcases `string`.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :upper)
      "HELLO"

  """
  @spec apply_case(String.t(), :upper | :lower) :: String.t()
  def apply_case(string, :upper), do: String.upcase(string)
  def apply_case(string, :lower), do: String.downcase(string)

  @doc """
  Reduces `string` to a lowercase ASCII token of letters and digits.

  Accented letters are decomposed first, so they keep their base letter
  (`"José"` becomes `"jose"`, not `"jos"`); every other character, such as a
  hyphen, apostrophe, or space, is dropped. `NeoFaker.Internet` relies on this
  to build usernames, domain labels, and slugs whose only separators are the
  ones it inserts itself.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.slugify("T-shirt")
      "tshirt"

      iex> NeoFaker.Helpers.Formatter.slugify("José")
      "jose"

  """
  @spec slugify(String.t()) :: String.t()
  def slugify(string) do
    string
    |> :unicode.characters_to_nfd_binary()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "")
  end
end
