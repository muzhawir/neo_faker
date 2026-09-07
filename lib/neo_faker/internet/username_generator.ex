defmodule NeoFaker.Internet.UsernameGenerator do
  @moduledoc false

  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Person

  @type word_type :: :person | :word
  @type separator_type :: :all | :dot | :underscore | :dash

  @doc """
  Generates a single lowercase alphanumeric word to use as one segment of a
  username.

  `:person` returns a random first or last name; `:word` returns a random
  common word. Either way the result is run through `Formatter.slugify/1`, so a
  name or word with a hyphen, apostrophe, space, or accent still yields a bare
  token. The caller (`NeoFaker.Internet.username/1`) joins multiple calls
  together with `joiner/1`; this function never combines words itself.
  """
  @spec word(word_type()) :: String.t()
  def word(type) do
    raw =
      case type do
        :person -> Enum.random([Person.first_name(), Person.last_name()])
        :word -> NeoFaker.Text.word()
      end

    Formatter.slugify(raw)
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
