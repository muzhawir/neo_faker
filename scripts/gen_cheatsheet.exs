# Regenerates lib/pages/reference/cheat.cheatmd from the `## Examples` section of
# every public function's @doc, so the cheatsheet never drifts from the API docs.
#
#     mix run scripts/gen_cheatsheet.exs

modules = [
  NeoFaker.Address,
  NeoFaker.App,
  NeoFaker.Blood,
  NeoFaker.Boolean,
  NeoFaker.Color,
  NeoFaker.Crypto,
  NeoFaker.Date,
  NeoFaker.Gravatar,
  NeoFaker.HTTP,
  NeoFaker.Internet,
  NeoFaker.Lorem,
  NeoFaker.Number,
  NeoFaker.Person,
  NeoFaker.Text,
  NeoFaker.Time
]

output = "lib/pages/reference/cheat.cheatmd"

examples = fn doc ->
  case String.split(doc, "## Examples\n", parts: 2) do
    [_, rest] ->
      rest
      |> String.split("\n")
      |> Enum.map_join("\n", &String.replace_prefix(&1, "    ", ""))
      |> String.trim()

    [_] ->
      nil
  end
end

section = fn module ->
  {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)
  name = module |> Module.split() |> List.last()

  functions =
    for {{:function, fun, arity}, anno, [signature], %{"en" => doc}, _meta} <- docs,
        example = examples.(doc),
        example != nil do
      {:erl_anno.line(anno),
       "### [`#{signature}`](`#{inspect(module)}.#{fun}/#{arity}`)\n\n```elixir\n#{example}\n```"}
    end

  body = functions |> Enum.sort() |> Enum.map_join("\n\n", &elem(&1, 1))

  "## [#{name}](`#{inspect(module)}`)\n\n{: .col-2}\n\n#{body}"
end

header = """
# Cheatsheet

Every domain generator on one page, grouped by module. Each entry links to the full
documentation, which lists every option. Functions whose options all have defaults can be
called with no arguments. For country-specific formats that do not fit a shared `:locale`
option, such as US Social Security Numbers or Indonesian NIK numbers, see the
[Locale Cheatsheet](locale-cheat.html).

Generated values are random, so the results shown are examples only.
"""

File.write!(output, header <> "\n" <> Enum.map_join(modules, "\n\n", section) <> "\n")
IO.puts("Wrote #{output}")
