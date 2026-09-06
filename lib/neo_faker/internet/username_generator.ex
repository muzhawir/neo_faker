defmodule NeoFaker.Internet.UsernameGenerator do
  @moduledoc false

  alias NeoFaker.Person

  @type word_type :: :person | :word
  @type separator_type :: :all | :dot | :underscore | :dash

  @doc """
  Generates a single lowercase word to use as one segment of a username.

  `:person` returns a random first or last name; `:word` returns a random
  common word. The caller (`NeoFaker.Internet.username/1`) joins multiple
  calls together with `joiner/1`; this function never combines words itself.
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
  Returns the separator character placed between username word segments.

  `:all` picks one of `.`, `_`, or `-` at random; the other types return
  their fixed character directly.
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
