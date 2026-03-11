defmodule NeoFaker.App.Domain do
  @moduledoc false

  @doc """
  Sanitises and reverses a domain string into a dot-separated identifier prefix.

  Each label is lowercased and stripped of any character that is not a lowercase
  ASCII letter or digit. Empty labels (including those that become empty after
  stripping) are discarded. The surviving labels are then reversed and joined
  with dots.

  This ensures the resulting prefix is safe for use in both Apple bundle
  identifiers (which allow hyphens only in the app-name segment, not in the
  domain prefix) and Java/Android package names (which require pure alphanumeric
  components).

  Raises `ArgumentError` when every label is empty after sanitisation, e.g. a
  domain consisting entirely of dots or special characters.

  ## Examples

      iex> NeoFaker.App.Domain.reverse_domain!("example.com")
      "com.example"

      iex> NeoFaker.App.Domain.reverse_domain!("my-company.io")
      "io.mycompany"

      iex> NeoFaker.App.Domain.reverse_domain!("MyCompany.IO")
      "io.mycompany"

      iex> NeoFaker.App.Domain.reverse_domain!("my-app.my-company.io")
      "io.mycompany.myapp"

  """
  @spec reverse_domain!(String.t()) :: String.t()
  def reverse_domain!(domain) do
    labels =
      domain
      |> String.split(".", trim: true)
      |> Enum.map(&String.downcase/1)
      |> Enum.map(&String.replace(&1, ~r/[^a-z0-9]/, ""))
      |> Enum.reject(&(&1 == ""))

    case Enum.reverse(labels) do
      [] ->
        raise ArgumentError,
              "domain #{inspect(domain)} produced no valid labels after sanitisation. " <>
                "Expected a domain such as \"example.com\"."

      reversed ->
        Enum.join(reversed, ".")
    end
  end
end
