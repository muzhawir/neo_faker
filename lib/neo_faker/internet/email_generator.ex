defmodule NeoFaker.Internet.Email do
  @moduledoc false

  alias NeoFaker.Internet

  @doc """
  Generates a random user name for an email address.

  Returns a random username string.
  """
  @spec generate_username(Keyword.t()) :: String.t()
  def generate_username(opts) do
    word_count = Keyword.get(opts, :username_word_count, Keyword.get(opts, :word_count, 2))

    username_opts =
      opts
      |> Keyword.take([:word_count, :joiner, :username_type, :number, :number_range])
      |> Keyword.put(:word_count, word_count)

    Internet.username(username_opts)
  end

  @doc """
  Generates a random domain name for an email address.

  Returns a random domain name string.
  """
  @spec generate_domain_name(Keyword.t()) :: String.t()
  def generate_domain_name(opts) do
    word_count = Keyword.get(opts, :domain_name_word_count, Keyword.get(opts, :word_count, 1))
    type = Keyword.get(opts, :domain_type, Keyword.get(opts, :type, :random))

    domain_name_opts =
      opts
      |> Keyword.take([:word_count, :type, :popular_type, :domain_name])
      |> Keyword.put(:word_count, word_count)
      |> Keyword.put(:type, type)

    Internet.domain_name(domain_name_opts)
  end

  @doc """
  Generates a random top-level domain (TLD) for an email address.

  Returns a random TLD string.
  """
  @spec generate_tld(Keyword.t()) :: String.t()
  def generate_tld(opts) do
    type = Keyword.get(opts, :tld_type, Keyword.get(opts, :type, :all_except_safe))

    tld_opts =
      opts
      |> Keyword.take([:type, :dot])
      |> Keyword.put(:type, type)

    Internet.tld(tld_opts)
  end
end
