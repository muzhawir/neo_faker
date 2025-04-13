import Config

# Sets the default locale for NeoFaker.
# This determines the language and regional data used by the library.
# Available locales can be found at: https://hexdocs.pm/neo_faker/available-locales.html

if Mix.env() in [:dev, :test] do
  config :neo_faker, locale: :default
end
