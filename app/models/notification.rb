class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_order

  # Enums
  enum :notification_type, {
    new_order: 0,
    order_accepted: 1,
    status_update: 2,
    delivery_complete: 3,
    payment_authorized: 4,
    payment_captured: 5
  }, prefix: true

  # Validations
  validates :user, presence: true
  validates :delivery_order, presence: true
  validates :notification_type, presence: true
  validates :message, presence: true

  # Scopes
  scope :unread, -> { where(is_read: false, is_expired: false) }
  scope :active, -> { where(is_expired: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def mark_as_read!
    update!(is_read: true)
  end

  def expire!
    update!(is_expired: true)
  end
end
