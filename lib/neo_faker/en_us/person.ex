defmodule NeoFaker.EnUs.Person do
  @moduledoc """
  Testing EN US generator
  """
  import NeoFaker.Helper.Generator

  @doc """
  should return a random first name
  """
  def first_name do
    random(NeoFaker.EnUs.Person, "gender.exs", "non_binary")
  end
end
