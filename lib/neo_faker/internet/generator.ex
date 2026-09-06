defmodule NeoFaker.Internet.Generator do
  @moduledoc false

  # ---------------------------------------------------------------------------
  # IANA special-purpose blocks excluded from public_ipv4/0 (iana.org):
  #
  #   0.0.0.0/8        – "This" network (RFC 791 / RFC 1122)
  #   10.0.0.0/8       – RFC 1918 private class A
  #   100.64.0.0/10    – Shared address / CGN (RFC 6598); second octets 64–127
  #   127.0.0.0/8      – Loopback (RFC 1122)
  #   169.254.0.0/16   – Link-local (RFC 3927); second octet 254 only
  #   172.16.0.0/12    – RFC 1918 private class B; second octets 16–31
  #   192.0.0.0/24     – IETF protocol assignments (RFC 6890); second=0, all thirds
  #   192.0.2.0/24     – TEST-NET-1 (RFC 5737); second=0, third=2 (covered above)
  #   192.88.99.0/24   – Deprecated 6to4 relay (RFC 7526); second=88, third=99
  #   192.168.0.0/16   – RFC 1918 private class C; second=168, all thirds
  #   198.18.0.0/15    – Benchmarking (RFC 2544); second octets 18–19
  #   198.51.100.0/24  – TEST-NET-2 (RFC 5737); second=51, third=100
  #   203.0.113.0/24   – TEST-NET-3 (RFC 5737); second=0, third=113
  #   224.0.0.0/4      – Multicast (RFC 3171)
  #   240.0.0.0/4      – Reserved / broadcast (RFC 1112)
  #
  # Strategy: the first-octet table covers every /8 that contains at least one
  # public address. Octets with mixed public/reserved sub-ranges (100, 169, 172,
  # 192, 198, 203) are weighted by their count of valid second octets and then
  # have their narrow reserved sub-ranges excluded in pick_public_second_octet/1
  # or pick_public_third_octet/2.
  # ---------------------------------------------------------------------------

  # Weights for mixed-range first octets (valid second-octet counts out of 256):
  #
  #   100 – 100.64–127 reserved (/10 = 64 second octets); 256 − 64 = 192 valid
  #   169 – 169.254 reserved (/16 = 1 second octet);      256 −  1 = 255 valid
  #   172 – 172.16–31 reserved (/12 = 16 second octets);  256 − 16 = 240 valid
  #   192 – second=0 (/24, IETF) and second=168 (/16, RFC1918) fully excluded;
  #         second=88 and second=51 are public but need third-octet guards → 254 valid
  #   198 – second=18,19 (/15) fully excluded; second=51 needs third-octet guard → 253 valid (254 − 1 for the /15)
  #         Wait – 198: exclude 18,19 (fully reserved /15) → 254 valid second octets
  #   203 – second=0, third=113 only; all 256 second octets valid (guard in third)
  #
  # Re-deriving 192: exclude second=0 (covers both 192.0.0.0/24 and 192.0.2.0/24)
  # and second=168 (192.168.0.0/16). second=88 stays (only /24 reserved, handled
  # in pick_public_third_octet). → 256 − 2 = 254 valid second octets.
  #
  # Re-deriving 198: exclude second=18 and second=19 (198.18.0.0/15). second=51
  # stays (only one /24 reserved, handled in pick_public_third_octet).
  # → 256 − 2 = 254 valid second octets.

  # The table is a list of {weight, lo, hi} ranges of first octets.
  # Pure-public /8 blocks each have weight 256 (all second octets valid).
  # Mixed blocks carry their actual valid-second-octet count as weight.
  @public_first_octet_ranges [
    # weight, lo, hi
    {256, 1, 9},
    {256, 11, 99},
    {192, 100, 100},
    {256, 101, 126},
    {256, 128, 168},
    {255, 169, 169},
    {240, 172, 172},
    {256, 173, 191},
    {254, 192, 192},
    {256, 193, 197},
    {254, 198, 198},
    {256, 199, 202},
    {256, 203, 203},
    {256, 204, 223}
  ]

  # Pre-compute the cumulative weight table at compile time so public_ipv4/0
  # costs only a single :rand.uniform/1 call for the first octet.
  {entries, total} =
    Enum.map_reduce(@public_first_octet_ranges, 0, fn {weight, lo, hi}, cumulative ->
      range_weight = weight * (hi - lo + 1)
      new_cumulative = cumulative + range_weight
      {{new_cumulative, weight, lo, hi}, new_cumulative}
    end)

  @first_octet_table {entries, total}

  @first_octet_entries elem(@first_octet_table, 0)
  @first_octet_total elem(@first_octet_table, 1)

  @doc """
  Returns `true` when the address `a.b.c.x` falls inside any IANA special-purpose
  block that `public_ipv4/0` excludes; `false` when the address is publicly routable.

  Only the first three octets are required because every reserved block that is
  narrower than a /24 is fully identified by `{a, b, c}`, so the fourth octet never
  changes the classification.

  Reserved ranges checked (RFC references match the module-level comment):

  - `0.x.x.x` covers the "This" network (RFC 791)
  - `10.x.x.x` covers RFC 1918 private class A
  - `100.64–127.x.x` covers carrier-grade NAT / CGN (RFC 6598)
  - `127.x.x.x` covers loopback (RFC 1122)
  - `169.254.x.x` covers link-local (RFC 3927)
  - `172.16–31.x.x` covers RFC 1918 private class B
  - `192.0.x.x` covers IETF protocol assignments and TEST-NET-1 (RFC 6890 / RFC 5737)
  - `192.88.99.x` covers the deprecated 6to4 relay anycast (RFC 7526)
  - `192.168.x.x` covers RFC 1918 private class C
  - `198.18–19.x.x` covers benchmarking (RFC 2544)
  - `198.51.100.x` covers TEST-NET-2 (RFC 5737)
  - `203.0.113.x` covers TEST-NET-3 (RFC 5737)
  - `224–255.x.x.x` covers multicast and reserved/broadcast (RFC 3171 / RFC 1112)
  """
  @spec reserved_ipv4?(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: boolean()
  def reserved_ipv4?(a, _b, _c) when a == 0, do: true
  def reserved_ipv4?(a, _b, _c) when a == 10, do: true
  def reserved_ipv4?(a, b, _c) when a == 100 and b in 64..127, do: true
  def reserved_ipv4?(a, _b, _c) when a == 127, do: true
  def reserved_ipv4?(a, b, _c) when a == 169 and b == 254, do: true
  def reserved_ipv4?(a, b, _c) when a == 172 and b in 16..31, do: true
  def reserved_ipv4?(a, b, _c) when a == 192 and b == 0, do: true
  def reserved_ipv4?(a, b, c) when a == 192 and b == 88 and c == 99, do: true
  def reserved_ipv4?(a, b, _c) when a == 192 and b == 168, do: true
  def reserved_ipv4?(a, b, _c) when a == 198 and b in 18..19, do: true
  def reserved_ipv4?(a, b, c) when a == 198 and b == 51 and c == 100, do: true
  def reserved_ipv4?(a, b, c) when a == 203 and b == 0 and c == 113, do: true
  def reserved_ipv4?(a, _b, _c) when a in 224..255, do: true
  def reserved_ipv4?(_a, _b, _c), do: false

  @doc """
  Generates a random publicly routable IPv4 address.

  Returns a string in the form `"A.B.C.D"` where the address is guaranteed to
  fall outside all IANA special-purpose ranges, including:

  - `0.0.0.0/8` covers the "This" network (RFC 791)
  - `10.0.0.0/8` covers RFC 1918 private class A
  - `100.64.0.0/10` covers the shared address space / carrier-grade NAT (RFC 6598)
  - `127.0.0.0/8` covers loopback (RFC 1122)
  - `169.254.0.0/16` covers link-local (RFC 3927)
  - `172.16.0.0/12` covers RFC 1918 private class B
  - `192.0.0.0/24` covers IETF protocol assignments (RFC 6890)
  - `192.0.2.0/24` covers TEST-NET-1 (RFC 5737)
  - `192.88.99.0/24` covers the deprecated 6to4 relay anycast (RFC 7526)
  - `192.168.0.0/16` covers RFC 1918 private class C
  - `198.18.0.0/15` covers benchmarking (RFC 2544)
  - `198.51.100.0/24` covers TEST-NET-2 (RFC 5737)
  - `203.0.113.0/24` covers TEST-NET-3 (RFC 5737)
  - `224.0.0.0/4` covers multicast (RFC 3171)
  - `240.0.0.0/4` covers reserved/broadcast addresses (RFC 1112)

  All other addresses in `1.0.0.0`–`223.255.255.255` are eligible, including
  the public portions of `100.x`, `169.x`, `172.x`, `192.x`, `198.x`, and
  `203.x` that fall outside the reserved sub-blocks above.
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

  # Each table entry is {cumulative_weight, per_octet_weight, lo, hi}.
  # Within a range all first octets are equally weighted, so we first find
  # which range n falls into, then pick uniformly within that range.
  @spec find_octet_in_table(list(), pos_integer()) :: non_neg_integer()
  defp find_octet_in_table([{cumulative, weight, lo, hi} | rest], n) do
    if n <= cumulative do
      # How far into this range is n?  Subtract the weight of all previous
      # ranges, then divide by per-octet weight to get the range offset.
      prev_cumulative = cumulative - weight * (hi - lo + 1)
      offset = div(n - prev_cumulative - 1, weight)
      lo + offset
    else
      find_octet_in_table(rest, n)
    end
  end

  # ---------------------------------------------------------------------------
  # Second-octet guards for mixed public/reserved first octets.
  # Pure-public first octets fall through to the catch-all clause.
  # ---------------------------------------------------------------------------
  @spec pick_public_second_octet(non_neg_integer()) :: non_neg_integer()

  # Within 100.64.0.0/10, second octets 64–127 are CGN (RFC 6598).
  # 100.0–100.63 and 100.128–100.255 are public.
  defp pick_public_second_octet(100) do
    Enum.random(Enum.reject(0..255, &(&1 in 64..127)))
  end

  # Within 169.254.0.0/16, only second octet 254 is link-local (RFC 3927).
  defp pick_public_second_octet(169) do
    Enum.random(Enum.reject(0..255, &(&1 == 254)))
  end

  # Within 172.16.0.0/12, second octets 16–31 are RFC 1918 private (RFC 1918).
  defp pick_public_second_octet(172) do
    Enum.random(Enum.reject(0..255, &(&1 in 16..31)))
  end

  # 192: exclude second=0 entirely (covers 192.0.0.0/24 IETF assignments and
  #      192.0.2.0/24 TEST-NET-1, since both have second=0).
  #      Exclude second=168 (192.168.0.0/16 RFC 1918 class C).
  #      second=88 is kept; 192.88.99.0/24 is handled in pick_public_third_octet.
  defp pick_public_second_octet(192) do
    Enum.random(Enum.reject(0..255, &(&1 in [0, 168])))
  end

  # 198: exclude second=18 and second=19 (198.18.0.0/15 benchmarking, RFC 2544).
  #      second=51 is kept; 198.51.100.0/24 TEST-NET-2 is handled in
  #      pick_public_third_octet.
  defp pick_public_second_octet(198) do
    Enum.random(Enum.reject(0..255, &(&1 in 18..19)))
  end

  defp pick_public_second_octet(_first), do: :rand.uniform(256) - 1

  # ---------------------------------------------------------------------------
  # Third-octet guards for sub-/16 reservations.
  # ---------------------------------------------------------------------------
  @spec pick_public_third_octet(non_neg_integer(), non_neg_integer()) :: non_neg_integer()

  # 192.88.99.0/24 is the deprecated 6to4 relay anycast (RFC 7526).
  defp pick_public_third_octet(192, 88) do
    Enum.random(Enum.reject(0..255, &(&1 == 99)))
  end

  # 198.51.100.0/24 is TEST-NET-2 (RFC 5737).
  defp pick_public_third_octet(198, 51) do
    Enum.random(Enum.reject(0..255, &(&1 == 100)))
  end

  # 203.0.113.0/24 is TEST-NET-3 (RFC 5737).
  defp pick_public_third_octet(203, 0) do
    Enum.random(Enum.reject(0..255, &(&1 == 113)))
  end

  defp pick_public_third_octet(_first, _second), do: :rand.uniform(256) - 1

  @doc """
  Generates a random private IPv4 address for the specified class.

  - `:a` returns an address in the `10.0.0.0/8` range.
  - `:b` returns an address in the `172.16.0.0/12` range.
  - `:c` returns an address in the `192.168.0.0/16` range.
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
      NeoFaker.Text.word() |> String.downcase() |> slugify()
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
      key = NeoFaker.Text.word() |> String.downcase() |> slugify()
      value = :rand.uniform(1000)
      "#{key}=#{value}"
    end)
  end

  # Internal helpers

  # Replaces runs of whitespace with hyphens so that multi-word entries returned
  # by NeoFaker.Text.word/0 (e.g. "all right", "ice cream") become valid
  # single-token URL path segments and query-string keys (e.g. "all-right").
  @spec slugify(String.t()) :: String.t()
  defp slugify(word), do: String.replace(word, ~r/\s+/, "-")

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
