defmodule NeoFaker.Internet.Generator do
  @moduledoc false

  # ---------------------------------------------------------------------------
  # IANA-reserved first-octet ranges excluded from public_ipv4/0:
  #
  #   0          – "This" network (RFC 1122)
  #   10         – RFC 1918 private class A
  #   100        – 100.64.0.0/10 shared address / carrier-grade NAT (RFC 6598)
  #               (100.64–100.127 are reserved; we exclude the whole octet 100
  #                for simplicity since all of 100.x.x.x is CGN or otherwise
  #                unroutable in practice)
  #   127        – Loopback (RFC 1122)
  #   169        – 169.254.0.0/16 link-local (RFC 3927)
  #   172        – 172.16.0.0/12 RFC 1918 private class B
  #   192        – Several sub-ranges (RFC 1918 class C, TEST-NET, 6to4 relay,
  #               IETF protocol assignments) – handled per second octet below
  #   198        – 198.18.0.0/15 benchmarking (RFC 2544) and
  #               198.51.100.0/24 TEST-NET-2 (RFC 5737) – handled below
  #   203        – 203.0.113.0/24 TEST-NET-3 (RFC 5737) – handled below
  #   224–239    – Multicast (RFC 3171)
  #   240–255    – Reserved / broadcast (RFC 1112)
  #
  # Strategy: build a compact list of {first_octet, weight} pairs that cover
  # only the genuinely public /8 blocks, then select uniformly. For the three
  # first octets that have mixed public/reserved sub-ranges (192, 198, 203) we
  # pick them with the correct probability and then validate the sub-range with
  # a guard on the remaining octets.
  # ---------------------------------------------------------------------------

  # Each entry is {first_octet, count_of_valid_second_octets_0_to_255}.
  # Pure-public /8 blocks each contribute weight 1 (normalised).
  # 192: out of 256 possible second octets, the reserved ones are:
  #   0   (192.0.0.0/24  – IETF protocol assignments)
  #   2   (192.0.2.0/24  – TEST-NET-1)
  #   88  (192.88.99.0/24 – deprecated 6to4; whole /24 reserved)
  #   168 (192.168.0.0/16 – RFC 1918 class C)
  #   → 252 valid second octets out of 256
  # 198: reserved second octets are 18, 19 (benchmarking /15) and 51 (TEST-NET-2).
  #   → 253 valid second octets out of 256
  # 203: only 203.0.113.x is reserved.
  #   → all second octets are valid (we check the sub-range inline)

  # Public /8 blocks: 1–9, 11–99, 101–126, 128–168, 170–171, 173–191,
  #                   193–197, 199–202, 204–223
  # We encode this as a flat list of inclusive ranges of first octets:
  @public_first_octet_ranges [
    {1, 9},
    {11, 99},
    {101, 126},
    {128, 168},
    {170, 171},
    {173, 191},
    {193, 197},
    {199, 202},
    {204, 223}
  ]

  # Pre-compute the cumulative weight table at compile time so public_ipv4/0
  # costs only a single :rand.uniform/1 call for the first octet.
  {entries, total} =
    Enum.map_reduce(@public_first_octet_ranges, 0, fn {lo, hi}, cumulative ->
      new_cumulative = cumulative + (hi - lo + 1)
      {{new_cumulative, lo, hi}, new_cumulative}
    end)

  @first_octet_table {entries, total}

  @first_octet_entries elem(@first_octet_table, 0)
  @first_octet_total elem(@first_octet_table, 1)

  @doc """
  Generates a random publicly routable IPv4 address.

  Returns a string in the form `"A.B.C.D"` where the address is guaranteed to
  fall outside all IANA-reserved ranges, including:

  - `0.0.0.0/8` — "This" network
  - `10.0.0.0/8` — RFC 1918 private class A
  - `100.64.0.0/10` — Shared address / carrier-grade NAT (RFC 6598)
  - `127.0.0.0/8` — Loopback
  - `169.254.0.0/16` — Link-local (RFC 3927)
  - `172.16.0.0/12` — RFC 1918 private class B
  - `192.0.0.0/24` — IETF protocol assignments
  - `192.0.2.0/24` — TEST-NET-1 (RFC 5737)
  - `192.88.99.0/24` — Deprecated 6to4 relay anycast (RFC 7526)
  - `192.168.0.0/16` — RFC 1918 private class C
  - `198.18.0.0/15` — Benchmarking (RFC 2544)
  - `198.51.100.0/24` — TEST-NET-2 (RFC 5737)
  - `203.0.113.0/24` — TEST-NET-3 (RFC 5737)
  - `224.0.0.0/4` — Multicast
  - `240.0.0.0/4` — Reserved / broadcast
  """
  @spec public_ipv4() :: String.t()
  def public_ipv4 do
    first = pick_public_first_octet()
    second = pick_public_second_octet(first)
    third = pick_public_third_octet(first, second)
    fourth = :rand.uniform(256) - 1

    "#{first}.#{second}.#{third}.#{fourth}"
  end

  # Pick a first octet uniformly from the public /8 ranges.
  @spec pick_public_first_octet() :: 1..223
  defp pick_public_first_octet do
    n = :rand.uniform(@first_octet_total)
    find_octet_in_table(@first_octet_entries, n)
  end

  @spec find_octet_in_table(list(), pos_integer()) :: non_neg_integer()
  defp find_octet_in_table([{cumulative, lo, hi} | rest], n) do
    if n <= cumulative do
      # prev_cumulative is the total weight of all ranges before this one.
      # offset (0-based) into this range = n - prev_cumulative - 1
      prev_cumulative = cumulative - (hi - lo + 1)
      lo + (n - prev_cumulative - 1)
    else
      find_octet_in_table(rest, n)
    end
  end

  # For the mixed-public/reserved first octets we restrict the second octet to
  # avoid their reserved sub-ranges. All other first octets allow any second
  # octet (0–255).
  @spec pick_public_second_octet(non_neg_integer()) :: non_neg_integer()

  # 192: avoid 0 (IETF protocol assignments), 2 (TEST-NET-1),
  #      88 (deprecated 6to4 relay anycast), and 168 (RFC 1918 class C).
  defp pick_public_second_octet(192) do
    Enum.random(Enum.reject(0..255, &(&1 in [0, 2, 88, 168])))
  end

  # 198: avoid 18 and 19 (benchmarking /15) and 51 (TEST-NET-2).
  defp pick_public_second_octet(198) do
    Enum.random(Enum.reject(0..255, &(&1 in [18, 19, 51])))
  end

  defp pick_public_second_octet(_first), do: :rand.uniform(256) - 1

  # For the 203.0.113.0/24 TEST-NET-3 sub-range the reserved bits span two
  # octets (second=0, third=113), so we guard the third octet here.
  # All other first/second combinations allow any third octet (0–255).
  @spec pick_public_third_octet(non_neg_integer(), non_neg_integer()) :: non_neg_integer()

  defp pick_public_third_octet(203, 0) do
    Enum.random(Enum.reject(0..255, &(&1 == 113)))
  end

  defp pick_public_third_octet(_first, _second), do: :rand.uniform(256) - 1

  @doc """
  Generates a random private IPv4 address for the specified class.

  - `:a` — Returns an address in the `10.0.0.0/8` range.
  - `:b` — Returns an address in the `172.16.0.0/12` range.
  - `:c` — Returns an address in the `192.168.0.0/16` range.
  """
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

  @doc """
  Generates a random compressed IPv6 address.

  Returns a string using the compressed notation, collapsing the longest consecutive sequence
  of all-zero groups into `"::"` where applicable.
  """
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

  @doc """
  Generates a random URL path.

  Returns a string of 1 to 3 randomly selected lowercase word segments joined by `"/"`.
  """
  @spec url_path() :: String.t()
  def url_path do
    path_depth = :rand.uniform(3)

    Enum.map_join(1..path_depth, "/", fn _ ->
      String.downcase(NeoFaker.Text.word())
    end)
  end

  @doc """
  Generates a random URL query string.

  Returns a string of 1 to 3 key-value pairs joined by `"&"`, where each key is a random
  lowercase word and each value is a random integer between 1 and 1000.
  """
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
    |> Stream.with_index()
    |> Stream.chunk_by(fn {val, _} -> val == 0 end)
    |> Stream.filter(fn chunk ->
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
