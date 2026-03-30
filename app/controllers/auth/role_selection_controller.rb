# frozen_string_literal: true

module Auth
  class RoleSelectionController < ApplicationController
    include Authentication

    skip_before_action :set_current_user, only: [ :new, :create ]
    before_action :ensure_pending_oauth_user, only: [ :new, :create ]

    def new
      render inertia: "Auth/SelectRole", props: {
        user: session[:pending_oauth_user].slice("email", "name")
      }
    end

    def create
      oauth_data = session[:pending_oauth_user]

      # Validate role before creating user to avoid enum errors
      unless [ "customer", "driver" ].include?(params[:role])
        redirect_to auth_select_role_path, alert: "Please select a valid role."
        return
      end

      user = User.new(
        email: oauth_data["email"],
        name: oauth_data["name"],
        password: SecureRandom.hex(32), # Random password for OAuth users
        role: params[:role]
      )

      ActiveRecord::Base.transaction do
        if user.save
          # Create connected service to link OAuth account
          user.connected_services.create!(
            provider: oauth_data["provider"],
            uid: oauth_data["uid"]
          )

          session.delete(:pending_oauth_user)
          create_session_for(user)
          redirect_to after_login_path(user), notice: "Account created successfully."
        else
          redirect_to auth_select_role_path, alert: user.errors.full_messages.join(", ")
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to auth_select_role_path, alert: "Failed to create account: #{e.message}"
    end

    private

    def ensure_pending_oauth_user
      unless session[:pending_oauth_user]
        redirect_to login_path, alert: "No pending OAuth registration found."
      end
    end
  end
end
