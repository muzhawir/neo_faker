defmodule NeoFaker.Internet.UserName do
  @moduledoc false

  alias NeoFaker.Person

  @type word_type :: :person | :word
  @type separator_type :: :all | :dot | :underscore | :dash

  @doc """
  Generates a username by combining words with a specified separator.

  Returns a username string.
  """
  @spec word(word_type()) :: String.t()
  def word(type) do
    case type do
      :person ->
        [Person.first_name(), Person.last_name()] |> Enum.random() |> String.downcase()

      :word ->
        String.downcase(NeoFaker.Text.word())
    end
  end

  @doc """
  Returns a separator string based on the specified type.
  """
  @spec separator(separator_type()) :: String.t()
  def separator(type) do
    case type do
      :all -> Enum.random([".", "_", "-"])
      :dot -> "."
      :underscore -> "_"
      :dash -> "-"
      _ -> Enum.random([".", "_", "-"])
    end
  end
end
