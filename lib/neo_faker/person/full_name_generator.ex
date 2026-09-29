defmodule NeoFaker.Person.FullNameGenerator do
  @moduledoc false

  alias NeoFaker.Person.NameGenerator

  @doc """
  Returns a full name in `locale`: first, optional middle, and last name.

  `:unisex` is resolved to a concrete sex once per call, so the parts of one name are
  never drawn from different sexes.
  """
  @spec name(NameGenerator.sex(), atom() | nil, boolean()) :: String.t()
  def name(sex, locale, middle_name?) do
    sex = NameGenerator.resolve_sex(sex)

    keys =
      if middle_name?,
        do: ~w[first_names middle_names last_names],
        else: ~w[first_names last_names]

    Enum.map_join(keys, " ", &NameGenerator.name(locale, &1, sex))
  end
end
