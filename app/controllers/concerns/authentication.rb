module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    if session[:user_session_id].present?
      session_record = Session.find_by(id: session[:user_session_id])

      if session_record
        Current.user = session_record.user
        Current.session = session_record
      else
        # Clear invalid session from cookie
        session.delete(:user_session_id)
      end
    end
  end

  def authenticate
    unless Current.user
      redirect_to login_path, alert: "You must be signed in to access this page."
    end
  end

  def require_customer
    unless Current.user&.customer?
      render inertia: "Errors/Forbidden", status: :forbidden
    end
  end

  def require_driver
    unless Current.user&.driver?
      render inertia: "Errors/Forbidden", status: :forbidden
    end
  end

  def require_role(role)
    unless Current.user&.role == role.to_s
      render inertia: "Errors/Forbidden", status: :forbidden
    end
  end

  def current_user
    Current.user
  end

  def logged_in?
    Current.user.present?
  end

  # Create a new session for the given user
  # Sets up the session record and Current thread-local context
  def create_session_for(user)
    session_record = user.sessions.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
    session[:user_session_id] = session_record.id
    Current.user = user
    Current.session = session_record
  end

  # Determine the post-login redirect path based on user role
  def after_login_path(user)
    return root_path unless user

    case user.role
    when "customer"
      "/customer/dashboard"
    when "driver"
      "/driver/orders"
    else
      root_path
    end
  end
end
