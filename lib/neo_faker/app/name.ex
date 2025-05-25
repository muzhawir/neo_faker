defmodule NeoFaker.App.Name do
  @moduledoc false

  @type case_style :: nil | :camel_case | :pascal_case | :dashed | :underscore | :single

  @doc """
  Formats a tuple of first and last name into a string according to the specified case style.

  Supported formats include:
  - `nil`: Returns the full name as "first_name last_name" without case transformation.
  - `:camel_case`: Returns the name in camel case (lowercase first name, capitalized last name,
  no space).
  - `:pascal_case`: Returns the name in Pascal case (both names capitalized, no space).
  - `:dashed`: Returns the name with the first name capitalized and the last name as-is, joined by
  a dash.
  - `:underscore`: Returns the name in lowercase, joined by an underscore.
  - `:single`: Randomly selects either the first or last name, capitalizes it, and returns it as
  a single name.
  """
  @spec name_case({String.t(), String.t()}, case_style()) :: String.t()
  def name_case({first_name, last_name}, style) do
    case style do
      nil ->
        "#{first_name} #{last_name}"

      :camel_case ->
        "#{String.downcase(first_name)}#{String.capitalize(last_name)}"

      :pascal_case ->
        "#{String.capitalize(first_name)}#{String.capitalize(last_name)}"

      :dashed ->
        "#{String.capitalize(first_name)}-#{last_name}"

      :underscore ->
        "#{String.downcase(first_name)}_#{String.downcase(last_name)}"

      :single ->
        [first_name, last_name]
        |> Enum.random()
        |> String.capitalize()
    end
  end
end
