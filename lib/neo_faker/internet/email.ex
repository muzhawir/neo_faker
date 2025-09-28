defmodule NeoFaker.Internet.Email do
  @moduledoc false

  alias NeoFaker.Internet

  @doc """
  Generates a random user name for an email address.

  Returns a random user name string.
  """
  @spec generate_user_name(Keyword.t()) :: String.t()
  def generate_user_name(opts) do
    user_name_opts =
      Keyword.take(opts, [:word_count, :joiner, :username_type, :number, :number_range])

    Internet.user_name(
      Keyword.put(user_name_opts, :word_count, Keyword.get(opts, :user_name_word_count, 2))
    )
  end

  @doc """
  Generates a random domain name for an email address.

  Returns a random domain name string.
  """
  @spec generate_domain_name(Keyword.t()) :: String.t()
  def generate_domain_name(opts) do
    domain_name_opts = Keyword.take(opts, [:word_count, :type, :popular_type, :domain_name])

    domain_name_opts =
      domain_name_opts
      |> Keyword.put(:word_count, Keyword.get(opts, :domain_name_word_count, 1))
      |> Keyword.put(:type, Keyword.get(opts, :domain_type, Keyword.get(domain_name_opts, :type)))

    Internet.domain_name(domain_name_opts)
  end

  @doc """
  Generates a random top-level domain (TLD) for an email address.

  Returns a random TLD string.
  """
  @spec generate_tld(Keyword.t()) :: String.t()
  def generate_tld(opts) do
    tld_opts =
      opts
      |> Keyword.take([:type, :dot])
      |> Keyword.put(:type, Keyword.get(opts, :tld_type, Keyword.get(opts, :type)))

    Internet.tld(tld_opts)
  end
end
