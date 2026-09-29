# Generates both cheatsheets from the `## Examples` section of every public
# function's @doc, so they never drift from the API docs:
#
#   * lib/pages/reference/cheat.cheatmd        - domain modules (NeoFaker.*)
#   * lib/pages/reference/locale-cheat.cheatmd - locale-exclusive modules (NeoFaker.Locales.*)
#
# Modules are discovered from the compiled application, so a new module or
# function shows up without editing this script. Run it through the alias:
#
#     mix docs.cheatsheet          # write both files (`mix docs` runs this first)
#     mix docs.cheatsheet --check  # exit with status 1 if either file is stale

defmodule NeoFaker.Cheatsheet do
  @moduledoc false

  @domain_output "lib/pages/reference/cheat.cheatmd"
  @locale_output "lib/pages/reference/locale-cheat.cheatmd"

  # Public modules that are not generators.
  @excluded [NeoFaker, NeoFaker.Locale]

  # Section titles for NeoFaker.Locales.<Code>. A new locale-exclusive module
  # fails loudly here until its locale is named.
  @locale_names %{"EnUs" => "English (US)", "IdId" => "Indonesian"}

  @domain_header """
  # Cheatsheet

  Every domain generator on one page, grouped by module. Each entry links to the full
  documentation, which lists every option. Functions whose options all have defaults can be
  called with no arguments. For country-specific formats that do not fit a shared `:locale`
  option, such as US Social Security Numbers or Indonesian NIK numbers, see the
  [Locale Cheatsheet](locale-cheat.html).

  Generated values are random, so the results shown are examples only.
  """

  @locale_header """
  # Locale Cheatsheet

  Every locale-exclusive generator, grouped by locale. These cover country-specific formats
  that do not fit a shared `:locale` option: a US Social Security Number, for example, has no
  Indonesian equivalent. See [Locales](locales.html#locale-exclusive-generators) for
  background, and the [Cheatsheet](cheat.html) for the general-purpose generators.

  Generated values are random, so the results shown are examples only.
  """

  def run(argv) do
    {domain, locale} = Enum.split_with(documented_modules(), &(not locale_module?(&1)))

    files = [
      {@domain_output, render(@domain_header, Enum.map(domain, &domain_section/1))},
      {@locale_output, render(@locale_header, locale_sections(locale))}
    ]

    case argv do
      ["--check"] -> check(files)
      [] -> Enum.each(files, &write/1)
      _ -> Mix.raise("usage: mix docs.cheatsheet [--check]")
    end
  end

  defp documented_modules do
    modules =
      for module <- Application.spec(:neo_faker, :modules),
          module not in @excluded,
          # `@moduledoc false` modules have :hidden instead of a map.
          {:docs_v1, _, :elixir, _, moduledoc, _, _} <- [Code.fetch_docs(module)],
          is_map(moduledoc),
          do: module

    Enum.sort(modules)
  end

  defp locale_module?(module), do: match?(["NeoFaker", "Locales" | _], Module.split(module))

  defp domain_section(module) do
    name = module |> Module.split() |> List.last()
    "## [#{name}](`#{inspect(module)}`)\n\n{: .col-2}\n\n" <> entries(module, :short)
  end

  # One section per locale; entries show the full module name, since a locale
  # can have several modules with functions of the same name.
  defp locale_sections(modules) do
    modules
    |> Enum.group_by(fn module -> module |> Module.split() |> Enum.at(2) end)
    |> Enum.sort()
    |> Enum.map(fn {code, modules} ->
      title =
        Map.get(@locale_names, code) ||
          Mix.raise("add a section title for NeoFaker.Locales.#{code} to @locale_names")

      "## #{title}\n\n{: .col-2}\n\n" <> Enum.map_join(modules, "\n\n", &entries(&1, :qualified))
    end)
  end

  defp entries(module, style) do
    {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)

    # Keyed by source line, so entries follow the order of the module.
    entries =
      for {{:function, fun, arity}, anno, [signature], %{"en" => doc}, _meta} <- docs,
          example = examples(doc) do
        title = if style == :qualified, do: "#{inspect(module)}.#{signature}", else: signature

        {:erl_anno.line(anno),
         "### [`#{title}`](`#{inspect(module)}.#{fun}/#{arity}`)\n\n```elixir\n#{example}\n```"}
      end

    entries |> Enum.sort() |> Enum.map_join("\n\n", &elem(&1, 1))
  end

  defp examples(doc) do
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

  defp render(header, sections), do: header <> "\n" <> Enum.join(sections, "\n\n") <> "\n"

  defp write({path, content}) do
    File.write!(path, content)
    Mix.shell().info("Wrote #{path}")
  end

  defp check(files) do
    case Enum.reject(files, fn {path, content} -> File.read!(path) == content end) do
      [] ->
        Mix.shell().info("Cheatsheets are up to date")

      stale ->
        paths = Enum.map_join(stale, ", ", &elem(&1, 0))
        Mix.shell().error("Stale cheatsheets: #{paths}. Run `mix docs.cheatsheet`.")
        System.halt(1)
    end
  end
end

NeoFaker.Cheatsheet.run(System.argv())
