defmodule NeoFaker.Internet.UsernameGenerator do
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
  Returns a joiner string based on the specified type.
  """
  @spec joiner(separator_type()) :: String.t()
  def joiner(type) do
    case type do
      :all -> Enum.random([".", "_", "-"])
      :dot -> "."
      :underscore -> "_"
      :dash -> "-"
    end
  end
end
