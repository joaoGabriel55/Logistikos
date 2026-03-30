# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials.dig(:google, :client_id) || ENV.fetch("GOOGLE_OAUTH_CLIENT_ID", nil),
           Rails.application.credentials.dig(:google, :client_secret) || ENV.fetch("GOOGLE_OAUTH_CLIENT_SECRET", nil),
           {
             scope: "email,profile",
             prompt: "select_account",
             image_aspect_ratio: "square",
             image_size: 256,
             name: "google_oauth2"
           }
end

# Configure OmniAuth settings for CSRF protection
# Only allow POST requests to prevent CSRF attacks (required by omniauth-rails_csrf_protection)
OmniAuth.config.allowed_request_methods = [ :post ]

# In development/test, allow test mode
if Rails.env.development? || Rails.env.test?
  OmniAuth.config.test_mode = ENV["OMNIAUTH_TEST_MODE"] == "true"
end

# Handle OmniAuth failures gracefully
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
