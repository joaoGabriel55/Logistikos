# frozen_string_literal: true

module Auth
  class OmniauthCallbacksController < ApplicationController
    include Authentication

    skip_before_action :set_current_user
    skip_before_action :verify_authenticity_token

    def google_oauth2
      auth_hash = request.env["omniauth.auth"]

      if auth_hash.nil?
        redirect_to login_path, alert: "Authentication failed. Please try again."
        return
      end

      user = resolve_user_from_auth(auth_hash)

      if user
        # Found or connected existing user
        create_session_for(user)
        redirect_to after_login_path(user), notice: "Signed in successfully with Google."
      else
        # New user needs to select role
        session[:pending_oauth_user] = {
          "provider" => auth_hash.provider.to_s,
          "uid" => auth_hash.uid.to_s,
          "email" => auth_hash.info.email.to_s,
          "name" => auth_hash.info.name.to_s
        }
        redirect_to auth_select_role_path
      end
    end

    def failure
      redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
    end

    private

    def resolve_user_from_auth(auth_hash)
      provider = auth_hash.provider.to_s
      uid = auth_hash.uid.to_s
      email = auth_hash.info.email

      # Priority 1: Check if there's a currently authenticated user wanting to connect a new provider
      if Current.user
        # Connect this OAuth account to the current user if not already connected
        connected_service = Current.user.connected_services.find_or_create_by(provider: provider, uid: uid)
        return Current.user if connected_service.persisted?
      end

      # Priority 2: Check if this OAuth connection already exists
      connected_service = ConnectedService.find_by(provider: provider, uid: uid)
      return connected_service.user if connected_service

      # Priority 3: Check if user with matching email exists (requires prior sign-in)
      # This allows linking OAuth to existing email-based accounts
      existing_user = User.find_by(email: email)
      if existing_user
        # Create connected service to link this OAuth account
        existing_user.connected_services.create!(provider: provider, uid: uid)
        return existing_user
      end

      # Priority 4: Return nil to indicate new user needs to be created
      nil
    end
  end
end
