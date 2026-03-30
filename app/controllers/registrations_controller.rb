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
    user = User.new(registration_params.merge(role: :customer))

    if user.save
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

  private

  def registration_params
    params.permit(:email, :password, :password_confirmation, :name)
  end

  def redirect_if_authenticated
    redirect_to after_login_path(Current.user) if Current.user
  end
end
