defmodule NeoFaker.App.Name do
  @moduledoc false

  @doc """
  Converts a name into the specified case format.

  This function takes a tuple containing a first name and a last name, then formats it
  according to the given case style.
  """
  @spec name_case({String.t(), String.t()}, atom()) :: String.t()
  def name_case({first_name, last_name}, nil), do: "#{first_name} #{last_name}"

  def name_case({first_name, last_name}, :camel_case) do
    "#{String.downcase(first_name)}#{String.capitalize(last_name)}"
  end

  def name_case({first_name, last_name}, :pascal_case) do
    "#{String.capitalize(first_name)}#{String.capitalize(last_name)}"
  end

  def name_case({first_name, last_name}, :dashed) do
    "#{String.capitalize(first_name)}-#{last_name}"
  end

  def name_case({first_name, last_name}, :underscore) do
    "#{String.downcase(first_name)}_#{String.downcase(last_name)}"
  end

  def name_case({first_name, last_name}, :single) do
    [first_name, last_name] |> Enum.random() |> String.capitalize()
  end
end
