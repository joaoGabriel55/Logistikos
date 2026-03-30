class ApplicationController < ActionController::Base
  include InertiaRails::Controller
  include Authentication

  # Explicitly declare CSRF protection for security
  protect_from_forgery with: :exception

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Set CSRF token cookie for Inertia.js
  before_action :set_csrf_cookie

  private

  def set_csrf_cookie
    cookies["XSRF-TOKEN"] = {
      value: form_authenticity_token,
      same_site: :strict
    }
  end

  # Shared data available to all Inertia pages
  inertia_share do
    {
      auth: {
        user: Current.user ? {
          id: Current.user.id,
          email: Current.user.email,
          name: Current.user.name,
          role: Current.user.role
        } : nil
      },
      flash: {
        notice: flash[:notice],
        alert: flash[:alert]
      }
    }
  end
end
