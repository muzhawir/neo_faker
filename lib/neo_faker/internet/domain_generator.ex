defmodule NeoFaker.Internet.DomainGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @type domain_type :: :all | :ecommerce | :email | :search | :social

  @module NeoFaker.Internet

  @popular_domain_file "popular_domain.exs"

  @doc """
  Generates a popular domain name based on the specified type.

  Returns a random domain from the selected category, or from every category
  combined when `type` is `:all`.
  """
  @spec generate_popular_domain_name(domain_type()) :: String.t()
  def generate_popular_domain_name(type) do
    case type do
      :all -> fetch_popular_domain(:all)
      :ecommerce -> fetch_popular_domain(:ecommerce)
      :email -> fetch_popular_domain(:email)
      :search -> fetch_popular_domain(:search)
      :social -> fetch_popular_domain(:social)
    end
  end

  # :all flattens every category's list before picking, so each category
  # doesn't need to have the same number of entries for the pick to still be
  # roughly representative; a named type just picks from its own list.
  defp fetch_popular_domain(:all) do
    :default
    |> Data.fetch!(@module, @popular_domain_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  defp fetch_popular_domain(type) do
    :default
    |> Data.fetch!(@module, @popular_domain_file)
    |> Map.get(Atom.to_string(type))
    |> Enum.random()
  end
end
