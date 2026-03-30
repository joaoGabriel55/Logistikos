class Session < ApplicationRecord
  belongs_to :user

  # Validations
  validates :user, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Methods
  def self.cleanup_old_sessions(days = 30)
    where("created_at < ?", days.days.ago).delete_all
  end
end
