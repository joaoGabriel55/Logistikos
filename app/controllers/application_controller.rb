class ApplicationController < ActionController::Base
  include InertiaRails::Controller

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Shared data available to all Inertia pages
  # NOTE: Authentication state sharing will be added here once ticket 002
  # (Rails 8 built-in authentication) is implemented:
  #
  # inertia_share do
  #   {
  #     auth: {
  #       user: Current.user&.slice(:id, :email, :name, :role)
  #     },
  #     flash: {
  #       notice: flash[:notice],
  #       alert: flash[:alert]
  #     }
  #   }
  # end
end
