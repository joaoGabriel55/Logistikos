# frozen_string_literal: true

class SessionsController < ApplicationController
  include Authentication

  skip_before_action :set_current_user, only: [ :new, :create ]
  before_action :redirect_if_authenticated, only: [ :new, :create ]

  def new
    render inertia: "Auth/Login", props: {
      googleOAuthUrl: "/auth/google_oauth2"
    }
  end

  def create
    # Validate required fields
    if params[:email].blank?
      return render inertia: "Auth/Login", props: {
        googleOAuthUrl: "/auth/google_oauth2",
        errors: { email: "Email can't be blank" }
      }
    end

    if params[:password].blank?
      return render inertia: "Auth/Login", props: {
        googleOAuthUrl: "/auth/google_oauth2",
        errors: { password: "Password can't be blank" }
      }
    end

    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      create_session_for(user)
      redirect_to after_login_path(user), notice: "Signed in successfully."
    else
      # Generic error message to prevent user enumeration
      render inertia: "Auth/Login", props: {
        googleOAuthUrl: "/auth/google_oauth2",
        errors: { email: "Invalid email or password" }
      }
    end
  end

  def destroy
    if Current.session
      Current.session.destroy
      Current.reset
    end

    reset_session
    redirect_to login_path, notice: "Signed out successfully."
  end

  private

  def redirect_if_authenticated
    redirect_to after_login_path(Current.user) if Current.user
  end
end
