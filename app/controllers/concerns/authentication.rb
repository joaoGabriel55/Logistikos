module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    if (session_record = Session.find_by(id: session[:session_id]))
      Current.user = session_record.user
      Current.session = session_record
    end
  end

  def authenticate
    redirect_to login_path, alert: "You must be signed in to access this page." unless Current.user
  end

  def require_role(role)
    unless Current.user&.role == role.to_s
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

  def current_user
    Current.user
  end

  def logged_in?
    Current.user.present?
  end
end
