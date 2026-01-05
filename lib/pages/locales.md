# Supported Locales

NeoFaker generates locale-specific data for realistic testing and development. Locale-aware
functions use data files from `priv/locales/<locale>/`. If a requested locale is missing, NeoFaker
falls back to the default (`:default`), which provides generic English (US) data.

For example, generate an app description in Indonesian:

```elixir
iex> NeoFaker.App.description(locale: :id_id)
"Penghasil data palsu untuk pengujian dan lingkungan pengembangan Elixir."
```

This looks for data in `priv/locales/id_id/`. If unavailable, it falls back to
`priv/locales/default/`.

To set the locale, use the `locale` option in the function call. See
[configuration instructions](getting-started.html#configuration) for details.

Here are the currently supported locales:

| Locale     | Country      | Language                           |
| ---------- | ------------ | ---------------------------------- |
| `:default` | 🌐 N/A       | English (US), not country-specific |
| `:id_id`   | 🇮🇩 Indonesia | Bahasa Indonesia                   |
