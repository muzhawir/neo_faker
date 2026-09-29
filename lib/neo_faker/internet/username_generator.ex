defmodule NeoFaker.Internet.UsernameGenerator do
  @moduledoc false

  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Person
  alias NeoFaker.Text

  @joiners [dot: ".", underscore: "_", dash: "-"]

  @type word_type :: :person | :word
  @type joiner :: :all | :dot | :underscore | :dash

  @doc """
  Returns a username of `count` segments joined by one joiner, with an optional
  numeric suffix drawn from `number_range` (`nil` for none).
  """
  @spec username(pos_integer(), joiner(), word_type(), Range.t() | nil) :: String.t()
  def username(count, joiner, word_type, number_range) do
    joiner = joiner(joiner)
    segments = Enum.map(1..count, fn _ -> word(word_type) end)

    segments
    |> append_number(number_range)
    |> Enum.join(joiner)
  end

  @doc """
  Returns one lowercase alphanumeric username segment.

  `:person` draws a first or last name and `:word` draws a common word; either way the
  result is passed through `NeoFaker.Helpers.Formatter.slugify/1`, so hyphens,
  apostrophes, and accents never leak into the username.
  """
  @spec word(word_type()) :: String.t()
  def word(:person) do
    name =
      case Enum.random([:first, :last]) do
        :first -> Person.first_name()
        :last -> Person.last_name()
      end

    Formatter.slugify(name)
  end

  def word(:word), do: Formatter.slugify(Text.word())

  @doc """
  Returns the separator for `type`; `:all` picks one of the three at random.
  """
  @spec joiner(joiner()) :: String.t()
  def joiner(:all), do: @joiners |> Keyword.values() |> Enum.random()
  def joiner(type), do: Keyword.fetch!(@joiners, type)

  defp append_number(segments, nil), do: segments
  defp append_number(segments, range), do: segments ++ [Integer.to_string(Enum.random(range))]
end
