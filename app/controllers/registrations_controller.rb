# frozen_string_literal: true

class RegistrationsController < ApplicationController
  include Authentication

  skip_before_action :set_current_user, only: [ :new, :create ]
  before_action :redirect_if_authenticated, only: [ :new, :create ]

  def new
    render inertia: "Auth/Register", props: {
      googleOAuthUrl: "/auth/google_oauth2"
    }
  end

  def create
    # Validate role before creating user to avoid enum errors
    unless [ "customer", "driver" ].include?(params[:role])
      render inertia: "Auth/Register", props: {
        googleOAuthUrl: "/auth/google_oauth2",
        errors: { role: "Please select a valid role" }
      }
      return
    end

    user = User.new(registration_params.merge(role: params[:role]))

    ActiveRecord::Base.transaction do
      if user.save
        # Create driver profile for driver users
        if user.driver?
          user.create_driver_profile!(
            vehicle_type: params[:vehicle_type] || :car,
            is_available: false,
            radius_preference_km: params[:radius_preference_km] || 10.0
          )
        end

        create_session_for(user)
        redirect_to after_login_path(user), notice: "Account created successfully."
      else
        # Format errors for Inertia.js (field => error message)
        formatted_errors = user.errors.messages.transform_values { |messages| messages.first }

        render inertia: "Auth/Register", props: {
          googleOAuthUrl: "/auth/google_oauth2",
          errors: formatted_errors
        }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render inertia: "Auth/Register", props: {
      googleOAuthUrl: "/auth/google_oauth2",
      errors: { base: "Failed to create account: #{e.message}" }
    }
  end

  private

  def registration_params
    params.permit(:email, :password, :password_confirmation, :name)
  end

  def redirect_if_authenticated
    redirect_to after_login_path(Current.user) if Current.user
  end
end
