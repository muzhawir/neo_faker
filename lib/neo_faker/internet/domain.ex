defmodule NeoFaker.Internet.Domain do
  @moduledoc false

  alias NeoFaker.Data.Cache

  @type domain_type :: :all | :ecommerce | :email | :search | :social | :default

  @module NeoFaker.Internet

  @popular_domain_file "popular_domain.exs"

  @doc """
  Generates a popular domain name based on the specified type.

  Returns a random domain from the selected category.
  """
  @spec generate_popular_domain_name(domain_type()) :: String.t()
  def generate_popular_domain_name(type) do
    case type do
      :all -> fetch_popular_domain(:all)
      :ecommerce -> fetch_popular_domain(:ecommerce)
      :email -> fetch_popular_domain(:email)
      :search -> fetch_popular_domain(:search)
      :social -> fetch_popular_domain(:social)
      _ -> fetch_popular_domain(:default)
    end
  end

  # Fetch popular domains based on type
  defp fetch_popular_domain(type) when type in [:all, :default] do
    :default
    |> Cache.fetch!(@module, @popular_domain_file)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  defp fetch_popular_domain(type) do
    :default
    |> Cache.fetch!(@module, @popular_domain_file)
    |> Map.get(Atom.to_string(type))
    |> Enum.random()
  end
end
