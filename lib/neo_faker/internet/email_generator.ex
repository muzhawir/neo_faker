defmodule NeoFaker.Internet.EmailGenerator do
  @moduledoc false

  alias NeoFaker.Internet

  @doc """
  Generates a random user name for an email address, from an already-validated
  `NeoFaker.Internet.email/1` options list.

  Returns a random username string.
  """
  @spec generate_username(keyword()) :: String.t()
  def generate_username(opts) do
    username_opts =
      opts
      |> Keyword.take([:joiner, :username_type, :number, :number_range])
      |> Keyword.put(:word_count, opts[:username_word_count])

    Internet.username(username_opts)
  end

  @doc """
  Generates a random domain name for an email address, from an already-validated
  `NeoFaker.Internet.email/1` options list.

  Returns a random domain name string.
  """
  @spec generate_domain_name(keyword()) :: String.t()
  def generate_domain_name(opts) do
    domain_name_opts =
      opts
      |> Keyword.take([:popular_type, :domain_name])
      |> Keyword.put(:word_count, opts[:domain_name_word_count])
      |> Keyword.put(:type, opts[:domain_type])

    Internet.domain_name(domain_name_opts)
  end

  @doc """
  Generates a random top-level domain (TLD) for an email address, from an
  already-validated `NeoFaker.Internet.email/1` options list.

  Returns a random TLD string, without a leading dot.
  """
  @spec generate_tld(keyword()) :: String.t()
  def generate_tld(opts) do
    Internet.tld(type: opts[:tld_type])
  end
end
