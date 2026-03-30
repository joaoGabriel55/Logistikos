class Session < ApplicationRecord
  belongs_to :user

  # Validations
  validates :user, presence: true

  # Filter sensitive attributes from logs
  self.filter_attributes = %i[ip_address user_agent]

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Callbacks
  before_save :hash_ip_address, if: -> { ip_address.present? && ip_address_changed? }
  before_save :truncate_user_agent, if: -> { user_agent.present? && user_agent_changed? }

  # Methods
  def self.cleanup_old_sessions(days = 30)
    where("created_at < ?", days.days.ago).delete_all
  end

  private

  def hash_ip_address
    # Hash IP address for privacy while maintaining ability to detect suspicious patterns
    self.ip_address = Digest::SHA256.hexdigest(ip_address)[0..15]
  end

  def truncate_user_agent
    # Keep only browser/OS info, truncate to 255 chars max
    self.user_agent = user_agent[0..254] if user_agent.length > 255
  end
end
