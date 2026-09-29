defmodule NeoFaker.App.DomainGenerator do
  @moduledoc false

  alias NeoFaker.Helpers.Formatter

  @doc """
  Reverses a domain into a dot-separated identifier prefix.

  Each label is reduced to lowercase ASCII letters and digits with
  `NeoFaker.Helpers.Formatter.slugify/1`, and labels left empty are dropped, so
  the prefix is valid in both Apple bundle identifiers and Java package names.

  Raises `ArgumentError` if no label survives.

  ## Examples

      iex> NeoFaker.App.DomainGenerator.reverse_domain!("my-app.My-Company.io")
      "io.mycompany.myapp"

  """
  @spec reverse_domain!(String.t()) :: String.t()
  def reverse_domain!(domain) do
    domain
    |> String.split(".")
    |> Enum.map(&Formatter.slugify/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reverse()
    |> case do
      [] ->
        raise ArgumentError,
              "domain #{inspect(domain)} has no alphanumeric labels, " <>
                "expected a domain such as \"example.com\""

      labels ->
        Enum.join(labels, ".")
    end
  end
end
