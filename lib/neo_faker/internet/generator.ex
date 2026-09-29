defmodule NeoFaker.Internet.Generator do
  @moduledoc false

  alias NeoFaker.Helpers.Formatter

  # Randomization backend for `NeoFaker.Internet`: IP and MAC addresses, URL
  # paths, and query strings. The public module owns option parsing and output
  # casing; everything here produces raw random values.
  #
  # Public IPv4 addresses are drawn without a rejection loop: the first octet
  # comes from the weighted table below, then the second and third octets skip
  # the reserved sub-blocks left inside that /8. The table is the single list of
  # IANA special-purpose blocks this module excludes (iana.org); every public
  # /8 must appear in it, and `reserved_ipv4?/3` encodes the same blocks as a
  # predicate for the tests.
  #
  # Each entry is {weight, lo, hi}: every first octet from lo to hi has `weight`
  # valid second octets, so one draw over the whole table is uniform per public
  # address rather than per first octet. First octets absent from the table are
  # reserved outright: 0 ("this" network, RFC 1122), 10 (private, RFC 1918),
  # 127 (loopback, RFC 1122), and 224-255 (multicast and reserved, RFC 3171 /
  # RFC 1112).
  @public_first_octet_ranges [
    {256, 1, 9},
    {256, 11, 99},
    # 100.64.0.0/10, shared address space / CGN (RFC 6598): 64 second octets.
    {192, 100, 100},
    {256, 101, 126},
    {256, 128, 168},
    # 169.254.0.0/16, link-local (RFC 3927): 1 second octet.
    {255, 169, 169},
    {256, 170, 171},
    # 172.16.0.0/12, private (RFC 1918): 16 second octets.
    {240, 172, 172},
    {256, 173, 191},
    # 192.0.0.0/24 and 192.0.2.0/24 (RFC 6890 / RFC 5737) exclude second octet
    # 0 entirely; 192.168.0.0/16 (RFC 1918) excludes 168. 192.88.99.0/24
    # (6to4 relay, RFC 7526) is excluded at the third octet.
    {254, 192, 192},
    {256, 193, 197},
    # 198.18.0.0/15, benchmarking (RFC 2544): 2 second octets.
    # 198.51.100.0/24 (TEST-NET-2, RFC 5737) is excluded at the third octet.
    {254, 198, 198},
    {256, 199, 202},
    # 203.0.113.0/24 (TEST-NET-3, RFC 5737) is excluded at the third octet.
    {256, 203, 203},
    {256, 204, 223}
  ]

  # Cumulative weights, computed at compile time, so the first octet costs a
  # single :rand.uniform/1 call. Each entry is {cumulative, weight, lo, hi}.
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
  Returns `true` if `a.b.c.x` is in a block excluded from `public_ipv4/0`.

  Three octets are enough because no excluded block is narrower than a /24.
  The blocks are listed with `@public_first_octet_ranges`.
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
  Returns a random publicly routable IPv4 address, uniformly distributed over
  every address outside the blocks listed with `@public_first_octet_ranges`.
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

  # Second octets excluded for the mixed first octets in the table.
  @spec pick_public_second_octet(non_neg_integer()) :: non_neg_integer()
  defp pick_public_second_octet(100), do: random_octet_except(64..127)
  defp pick_public_second_octet(169), do: random_octet_except([254])
  defp pick_public_second_octet(172), do: random_octet_except(16..31)
  defp pick_public_second_octet(192), do: random_octet_except([0, 168])
  defp pick_public_second_octet(198), do: random_octet_except(18..19)
  defp pick_public_second_octet(_first), do: random_octet()

  # The /24 blocks excluded at the third octet. A `def` rather than `defp` so
  # tests can hit these narrow branches directly instead of waiting for
  # `public_ipv4/0` to draw the matching second octet.
  @doc false
  @spec pick_public_third_octet(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def pick_public_third_octet(192, 88), do: random_octet_except([99])
  def pick_public_third_octet(198, 51), do: random_octet_except([100])
  def pick_public_third_octet(203, 0), do: random_octet_except([113])
  def pick_public_third_octet(_first, _second), do: random_octet()

  # ---------------------------------------------------------------------------
  # IPv6
  # ---------------------------------------------------------------------------

  @doc """
  Generates a random IPv6 address in full form: eight groups of four lowercase
  hex digits.
  """
  @spec ipv6() :: String.t()
  def ipv6 do
    Enum.map_join(1..8, ":", fn _ ->
      random_ipv6_group() |> Integer.to_string(16) |> String.pad_leading(4, "0")
    end)
  end

  @doc """
  Generates a random IPv6 address in compressed form (RFC 5952): leading zeros
  dropped and the longest run of two or more all-zero groups collapsed to `"::"`.
  """
  @spec compressed_ipv6() :: String.t()
  def compressed_ipv6 do
    1..8 |> Enum.map(fn _ -> random_ipv6_group() end) |> compress_ipv6_groups()
  end

  # ---------------------------------------------------------------------------
  # MAC address
  # ---------------------------------------------------------------------------

  @doc """
  Generates a random 48-bit MAC address: six two-digit hex octets joined by
  `separator`.
  """
  @spec mac_address(String.t()) :: String.t()
  def mac_address(separator) do
    Enum.map_join(1..6, separator, fn _ ->
      random_octet() |> Integer.to_string(16) |> String.pad_leading(2, "0")
    end)
  end

  # Renders a list of 16-bit groups in compressed notation: the longest run of
  # consecutive all-zero groups becomes `"::"` (earliest run on a tie, per
  # RFC 5952); an empty head or tail collapses to a leading/trailing `"::"`, and
  # an all-zero input becomes `"::"`.
  #
  # Split from `compressed_ipv6/0` so this formatting is a pure function of its
  # input, testable against fixed group lists rather than the ~1-in-4e9 odds of
  # two random groups both landing on zero. `@doc false` but a `def`: internal,
  # undocumented, reachable from tests.
  @doc false
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
  # Rejection sampling keeps the draw uniform over the remaining octets; at
  # most 64 of 256 values are ever excluded, so a retry is rare.
  @spec random_octet_except(Range.t() | list(non_neg_integer())) :: non_neg_integer()
  defp random_octet_except(excluded) do
    octet = random_octet()
    if octet in excluded, do: random_octet_except(excluded), else: octet
  end

  # Uniform random 16-bit group of an IPv6 address (0x0000..0xFFFF).
  @spec random_ipv6_group() :: non_neg_integer()
  defp random_ipv6_group, do: :rand.uniform(0x10_000) - 1

  # A single lowercase alphanumeric word from NeoFaker.Text, safe to drop into a
  # URL path segment or query-string key.
  @spec random_word_segment() :: String.t()
  defp random_word_segment, do: Formatter.slugify(NeoFaker.Text.word())
end
