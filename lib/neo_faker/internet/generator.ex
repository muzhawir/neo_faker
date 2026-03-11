defmodule NeoFaker.Internet.Generator do
  @moduledoc false

  @spec public_ipv4() :: String.t()
  def public_ipv4 do
    Enum.map_join(1..4, ".", fn _ -> :rand.uniform(256) - 1 end)
  end

  @spec private_ipv4(atom()) :: String.t()
  def private_ipv4(:a) do
    "10.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}"
  end

  def private_ipv4(:b) do
    "172.#{:rand.uniform(16) + 15}.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}"
  end

  def private_ipv4(:c) do
    "192.168.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}"
  end

  @spec compressed_ipv6() :: String.t()
  def compressed_ipv6 do
    groups = Enum.map(1..8, fn _ -> :rand.uniform(0x10_000) - 1 end)

    {start_idx, length} = find_longest_zero_sequence(groups)

    if length > 1 do
      before = Enum.take(groups, start_idx)
      after_groups = Enum.drop(groups, start_idx + length)

      before_str = format_ipv6_groups(before)
      after_str = format_ipv6_groups(after_groups)

      case {before_str, after_str} do
        {"", ""} -> "::"
        {"", _} -> "::#{after_str}"
        {_, ""} -> "#{before_str}::"
        _ -> "#{before_str}::#{after_str}"
      end
    else
      format_ipv6_groups(groups)
    end
  end

  @spec url_path() :: String.t()
  def url_path do
    path_depth = :rand.uniform(3)

    Enum.map_join(1..path_depth, "/", fn _ ->
      String.downcase(NeoFaker.Text.word())
    end)
  end

  @spec query_string() :: String.t()
  def query_string do
    param_count = :rand.uniform(3)

    Enum.map_join(1..param_count, "&", fn _ ->
      key = String.downcase(NeoFaker.Text.word())
      value = :rand.uniform(1000)
      "#{key}=#{value}"
    end)
  end

  # Internal helpers

  @spec find_longest_zero_sequence(list(integer())) :: {integer(), integer()}
  defp find_longest_zero_sequence(groups) do
    groups
    |> Enum.with_index()
    |> Enum.chunk_by(fn {val, _} -> val == 0 end)
    |> Enum.filter(fn chunk ->
      case chunk do
        [{0, _} | _] -> true
        _ -> false
      end
    end)
    |> Enum.max_by(fn chunk -> length(chunk) end, fn -> [] end)
    |> case do
      [] -> {0, 0}
      chunk -> {elem(hd(chunk), 1), length(chunk)}
    end
  end

  @spec format_ipv6_groups(list(integer())) :: String.t()
  defp format_ipv6_groups([]), do: ""

  defp format_ipv6_groups(groups) do
    Enum.map_join(groups, ":", &Integer.to_string(&1, 16))
  end
end
