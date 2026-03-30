# frozen_string_literal: true

class PagesController < ApplicationController
  # Smoke test route - renders the Home page component via Inertia.js
  def home
    render inertia: "Home"
  end
end
