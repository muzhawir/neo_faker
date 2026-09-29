defmodule NeoFaker.Internet.DomainGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @categories ~w[ecommerce email search social]

  @type category :: :all | :ecommerce | :email | :search | :social

  @doc """
  Returns a random popular domain from `category`, or from every category for `:all`.
  """
  @spec popular(category()) :: String.t()
  def popular(:all), do: random(@categories)
  def popular(category), do: random(Atom.to_string(category))

  defp random(keys) do
    Data.random_value(NeoFaker.Internet, "popular_domain.exs", keys, locale: :default)
  end
end
