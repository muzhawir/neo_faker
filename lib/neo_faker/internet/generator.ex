defmodule NeoFaker.Internet.Generator do
  @moduledoc false

  alias NeoFaker.Helpers.Formatter

  # Randomization backend for `NeoFaker.Internet`: IPv4/IPv6 addresses, URL
  # paths, and query strings. The public module owns option parsing and output
  # casing; everything here just produces raw random values.
  #
  # The one non-obvious piece is public IPv4 generation. Rather than "pick a
  # random address, retry if reserved", it walks the address space top-down
  # (first octet -> second -> third -> fourth), skipping reserved ranges at each
  # level, so every call returns a publicly routable address with no rejection
  # loop. `reserved_ipv4?/3` is the standalone predicate for the same rules and
  # is what the tests check against.

  # ---------------------------------------------------------------------------
  # IANA special-purpose blocks excluded from public_ipv4/0 (iana.org):
  #
  #   0.0.0.0/8        "This" network (RFC 791 / RFC 1122)
  #   10.0.0.0/8       RFC 1918 private class A
  #   100.64.0.0/10    Shared address / CGN (RFC 6598), second octets 64-127
  #   127.0.0.0/8      Loopback (RFC 1122)
  #   169.254.0.0/16   Link-local (RFC 3927), second octet 254 only
  #   172.16.0.0/12    RFC 1918 private class B, second octets 16-31
  #   192.0.0.0/24     IETF protocol assignments (RFC 6890), second=0, all thirds
  #   192.0.2.0/24     TEST-NET-1 (RFC 5737), second=0, third=2 (covered above)
  #   192.88.99.0/24   Deprecated 6to4 relay (RFC 7526), second=88, third=99
  #   192.168.0.0/16   RFC 1918 private class C, second=168, all thirds
  #   198.18.0.0/15    Benchmarking (RFC 2544), second octets 18-19
  #   198.51.100.0/24  TEST-NET-2 (RFC 5737), second=51, third=100
  #   203.0.113.0/24   TEST-NET-3 (RFC 5737), second=0, third=113
  #   224.0.0.0/4      Multicast (RFC 3171)
  #   240.0.0.0/4      Reserved / broadcast (RFC 1112)
  #
  # Strategy: the first-octet table covers every /8 that contains at least one
  # public address. A first octet with a mixed public/reserved range (100, 169,
  # 172, 192, 198, 203) is weighted by its count of valid second octets, so a
  # single :rand.uniform/1 draw over the whole table still lands on each
  # individual public address with equal probability, not on each first octet.
  # The narrow reserved sub-ranges inside those mixed octets are then excluded
  # in pick_public_second_octet/1 or pick_public_third_octet/2.
  # ---------------------------------------------------------------------------

  # Weights for mixed-range first octets (count of valid second octets, out of 256):
  #
  #   100  100.64-127 reserved (a /10, 64 second octets)   -> 256 - 64 = 192 valid
  #   169  169.254 reserved (a /16, 1 second octet)         -> 256 - 1  = 255 valid
  #   172  172.16-31 reserved (a /12, 16 second octets)     -> 256 - 16 = 240 valid
  #   192  second=0 (covers both the /24 IETF block and the /24 TEST-NET-1
  #        block) and second=168 (the /16 RFC 1918 block) are fully excluded;
  #        second=88 stays valid here since only its /24 sub-block is reserved,
  #        which is handled later in pick_public_third_octet/2 -> 254 valid
  #   198  second=18 and second=19 (the /15 benchmarking block) are fully
  #        excluded; second=51 stays valid here since only its /24 sub-block is
  #        reserved, which is handled later in pick_public_third_octet/2
  #        -> 254 valid
  #   203  no second octet is fully reserved (only third=113 under second=0
  #        is), so all 256 second octets stay valid here, guarded in the third
  #        octet instead

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
  # costs only a single :rand.uniform/1 call for the first octet. Each entry is
  # {cumulative_weight, per_octet_weight, lo, hi}.
  {octet_entries, octet_total} =
    Enum.map_reduce(@public_first_octet_ranges, 0, fn {weight, lo, hi}, cumulative ->
      cumulative = cumulative + weight * (hi - lo + 1)
      {{cumulative, weight, lo, hi}, cumulative}
    end)

  @first_octet_entries octet_entries
  @first_octet_total octet_total

  # ---------------------------------------------------------------------------
  # IPv4
  # ---------------------------------------------------------------------------

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
  def reserved_ipv4?(0, _b, _c), do: true
  def reserved_ipv4?(10, _b, _c), do: true
  def reserved_ipv4?(100, b, _c) when b in 64..127, do: true
  def reserved_ipv4?(127, _b, _c), do: true
  def reserved_ipv4?(169, 254, _c), do: true
  def reserved_ipv4?(172, b, _c) when b in 16..31, do: true
  def reserved_ipv4?(192, 0, _c), do: true
  def reserved_ipv4?(192, 88, 99), do: true
  def reserved_ipv4?(192, 168, _c), do: true
  def reserved_ipv4?(198, b, _c) when b in 18..19, do: true
  def reserved_ipv4?(198, 51, 100), do: true
  def reserved_ipv4?(203, 0, 113), do: true
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

    "#{first}.#{second}.#{third}.#{random_octet()}"
  end

  @doc """
  Generates a random private IPv4 address for the specified class.

  - `:a` returns an address in the `10.0.0.0/8` range.
  - `:b` returns an address in the `172.16.0.0/12` range.
  - `:c` returns an address in the `192.168.0.0/16` range.
  """
  @spec private_ipv4(atom()) :: String.t()
  def private_ipv4(:a), do: "10.#{random_octet()}.#{random_octet()}.#{random_octet()}"
  def private_ipv4(:b), do: "172.#{Enum.random(16..31)}.#{random_octet()}.#{random_octet()}"
  def private_ipv4(:c), do: "192.168.#{random_octet()}.#{random_octet()}"

  # Pick a first octet from the public /8 ranges, weighted so each individual
  # public address (not each first octet) is equally likely.
  @spec pick_public_first_octet() :: 1..223
  defp pick_public_first_octet do
    find_octet_in_table(@first_octet_entries, :rand.uniform(@first_octet_total))
  end

  # Walk the cumulative weight table to find which range `n` lands in, then map
  # it to a specific first octet within that range (all octets in a range share
  # the same per-octet weight, so the mapping is a plain division).
  @spec find_octet_in_table(list(), pos_integer()) :: non_neg_integer()
  defp find_octet_in_table([{cumulative, weight, lo, hi} | rest], n) do
    if n <= cumulative do
      prev_cumulative = cumulative - weight * (hi - lo + 1)
      lo + div(n - prev_cumulative - 1, weight)
    else
      find_octet_in_table(rest, n)
    end
  end

  # Second-octet guards for the mixed public/reserved first octets. Pure-public
  # first octets fall through to the catch-all clause.
  @spec pick_public_second_octet(non_neg_integer()) :: non_neg_integer()

  # 100.64.0.0/10 (second octets 64–127) is CGN / shared address space (RFC 6598).
  defp pick_public_second_octet(100), do: random_octet_except(64..127)

  # 169.254.0.0/16 (second octet 254) is link-local (RFC 3927).
  defp pick_public_second_octet(169), do: random_octet_except([254])

  # 172.16.0.0/12 (second octets 16–31) is RFC 1918 private class B.
  defp pick_public_second_octet(172), do: random_octet_except(16..31)

  # 192: second=0 covers 192.0.0.0/24 (IETF assignments) and 192.0.2.0/24
  # (TEST-NET-1); second=168 covers 192.168.0.0/16 (RFC 1918 class C). second=88
  # stays valid here — only 192.88.99.0/24 is reserved, guarded in the third octet.
  defp pick_public_second_octet(192), do: random_octet_except([0, 168])

  # 198: second=18/19 cover 198.18.0.0/15 (benchmarking, RFC 2544). second=51
  # stays valid here — only 198.51.100.0/24 is reserved, guarded in the third octet.
  defp pick_public_second_octet(198), do: random_octet_except(18..19)

  defp pick_public_second_octet(_first), do: random_octet()

  @doc """
  Picks a public third octet for a given first/second octet pair.

  Skips the sub-/16 reservations that survive the second-octet guard:

  - `192.88.99.0/24` covers the deprecated 6to4 relay anycast (RFC 7526)
  - `198.51.100.0/24` covers TEST-NET-2 (RFC 5737)
  - `203.0.113.0/24` covers TEST-NET-3 (RFC 5737)

  Any other pair returns a plain random octet. Public rather than private so the
  narrow reserved branches can be tested directly, instead of relying on
  `public_ipv4/0` drawing the exact second octet that reaches them.
  """
  @spec pick_public_third_octet(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def pick_public_third_octet(192, 88), do: random_octet_except([99])
  def pick_public_third_octet(198, 51), do: random_octet_except([100])
  def pick_public_third_octet(203, 0), do: random_octet_except([113])
  def pick_public_third_octet(_first, _second), do: random_octet()

  # ---------------------------------------------------------------------------
  # IPv6
  # ---------------------------------------------------------------------------

  @doc """
  Generates a random compressed IPv6 address.

  Returns a string using the compressed notation, collapsing the longest consecutive sequence
  of all-zero groups into `"::"` where applicable.
  """
  @spec compressed_ipv6() :: String.t()
  def compressed_ipv6 do
    1..8 |> Enum.map(fn _ -> random_ipv6_group() end) |> compress_ipv6_groups()
  end

  @doc """
  Renders a list of 16-bit groups as a compressed IPv6 address string.

  Collapses the longest run of consecutive all-zero groups into `"::"`; on a tie
  the earliest run wins, matching RFC 5952. An empty head or tail becomes a
  leading or trailing `"::"`, and an all-zero input becomes `"::"`.

  Split out from `compressed_ipv6/0` so the formatting can be tested against
  fixed group lists, without depending on two random groups independently
  landing on zero.
  """
  @spec compress_ipv6_groups(list(non_neg_integer())) :: String.t()
  def compress_ipv6_groups(groups) do
    {zero_start, zero_length} = find_longest_zero_sequence(groups)

    if zero_length > 1 do
      head = groups |> Enum.take(zero_start) |> format_ipv6_groups()
      tail = groups |> Enum.drop(zero_start + zero_length) |> format_ipv6_groups()

      head <> "::" <> tail
    else
      format_ipv6_groups(groups)
    end
  end

  # Returns `{start_index, length}` of the longest run of all-zero groups, or
  # `{0, 0}` when there is none. On a tie the earliest run wins, matching
  # RFC 5952's rule for choosing which run to compress (Enum.max_by keeps the
  # first of equal maxima).
  @spec find_longest_zero_sequence(list(integer())) :: {integer(), integer()}
  defp find_longest_zero_sequence(groups) do
    groups
    |> Enum.with_index()
    |> Enum.chunk_by(fn {group, _index} -> group == 0 end)
    |> Enum.filter(fn [{group, _index} | _] -> group == 0 end)
    |> Enum.max_by(&length/1, fn -> [] end)
    |> case do
      [] -> {0, 0}
      [{_group, start_index} | _] = run -> {start_index, length(run)}
    end
  end

  @spec format_ipv6_groups(list(integer())) :: String.t()
  defp format_ipv6_groups([]), do: ""
  defp format_ipv6_groups(groups), do: Enum.map_join(groups, ":", &Integer.to_string(&1, 16))

  # ---------------------------------------------------------------------------
  # URL parts
  # ---------------------------------------------------------------------------

  @doc """
  Generates a random URL path.

  Returns a string of 1 to 3 randomly selected lowercase word segments joined by `"/"`.
  """
  @spec url_path() :: String.t()
  def url_path do
    segment_count = :rand.uniform(3)

    Enum.map_join(1..segment_count, "/", fn _ -> random_word_segment() end)
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
      "#{random_word_segment()}=#{:rand.uniform(1000)}"
    end)
  end

  # ---------------------------------------------------------------------------
  # Random primitives
  # ---------------------------------------------------------------------------

  # Uniform random value of a single IPv4 octet (0..255).
  @spec random_octet() :: non_neg_integer()
  defp random_octet, do: :rand.uniform(256) - 1

  # Like random_octet/0 but never returns a value in `excluded` (a range or a
  # list), used to skip the reserved sub-ranges inside an otherwise-public /8.
  @spec random_octet_except(Range.t() | list(non_neg_integer())) :: non_neg_integer()
  defp random_octet_except(excluded) do
    0..255 |> Enum.reject(&(&1 in excluded)) |> Enum.random()
  end

  # Uniform random 16-bit group of an IPv6 address (0x0000..0xFFFF).
  @spec random_ipv6_group() :: non_neg_integer()
  defp random_ipv6_group, do: :rand.uniform(0x10_000) - 1

  # A single lowercase alphanumeric word from NeoFaker.Text, safe to drop into a
  # URL path segment or query-string key (Formatter.slugify/1 strips any hyphen,
  # apostrophe, or space a dictionary entry might carry).
  @spec random_word_segment() :: String.t()
  defp random_word_segment, do: Formatter.slugify(NeoFaker.Text.word())
end
