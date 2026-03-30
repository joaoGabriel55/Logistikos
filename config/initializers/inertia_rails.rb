# frozen_string_literal: true

InertiaRails.configure do |config|
  # Version handling for asset cache busting
  # Use Vite digest for asset versioning (will be available after vite_rails is installed)
  config.version = -> { ViteRuby.digest } if defined?(ViteRuby)

  # Disable SSR for MVP (client-side rendering only)
  # config.ssr_enabled = false  # This is the default

  # Comply with Inertia protocol by always including errors hash in responses
  config.always_include_errors_hash = true

  # NOTE: Shared data configuration (auth state, flash messages, etc.) will be added
  # in ApplicationController using `inertia_share` once authentication is implemented
  # in ticket 002. InertiaRails 3.x does not support config.shared_data in initializers.
end
