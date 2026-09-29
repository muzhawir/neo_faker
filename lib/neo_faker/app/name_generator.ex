defmodule NeoFaker.App.NameGenerator do
  @moduledoc false

  @type style :: nil | :camel_case | :pascal_case | :dashed | :underscore | :single

  @doc """
  Formats a `{first, last}` word pair in the given style.

  See `NeoFaker.App.name/1` for what each style produces.
  """
  @spec format_text({String.t(), String.t()}, style()) :: String.t()
  def format_text({first, last}, nil), do: "#{first} #{last}"

  def format_text({first, last}, :camel_case),
    do: String.downcase(first) <> String.capitalize(last)

  def format_text({first, last}, :pascal_case),
    do: String.capitalize(first) <> String.capitalize(last)

  def format_text({first, last}, :dashed), do: String.downcase("#{first}-#{last}")
  def format_text({first, last}, :underscore), do: String.downcase("#{first}_#{last}")

  def format_text({first, last}, :single),
    do: [first, last] |> Enum.random() |> String.capitalize()
end
