# Supported Locales

NeoFaker supports locale-specific data for realistic test output. Locale-aware functions load
data from `priv/data/<locale>/`. If the requested locale is unavailable, NeoFaker falls back
to `:default`, which provides generic English (US) data.

To set the locale globally, add the following to your `config.exs`:

```elixir
config :neo_faker, locale: :default
```

You can also override the locale for individual function calls. For example, to get the description in Indonesian:

```elixir
iex> NeoFaker.App.description(locale: :id_id)
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."
```

See the [configuration instructions](https://hexdocs.pm/neo_faker/getting-started.html#configuration) for more details.

## Available Locales

| Locale     | Country      | Language                           |
| ---------- | ------------ | ---------------------------------- |
| `:default` | 🌐 N/A       | English (US), not country-specific |
| `:id_id`   | 🇮🇩 Indonesia | Bahasa Indonesia                   |
