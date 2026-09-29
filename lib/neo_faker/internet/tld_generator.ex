defmodule NeoFaker.Internet.TldGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @real_categories ~w[generic sponsored country_code]

  @type type :: :all | :all_except_safe | :safe | :generic | :sponsored | :country_code

  @doc """
  Returns a random TLD, without a leading dot, from the given category.

  `:all_except_safe` pools every real, registrable category; `:all` also includes the
  reserved `"safe"` TLDs such as `example` and `test`.
  """
  @spec name(type()) :: String.t()
  def name(:all_except_safe), do: random(@real_categories)
  def name(:all), do: random(["safe" | @real_categories])
  def name(category), do: random(Atom.to_string(category))

  defp random(keys), do: Data.random_value(NeoFaker.Internet, "tld.exs", keys, locale: :default)
end
