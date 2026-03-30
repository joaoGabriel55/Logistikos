class Payment < ApplicationRecord
  belongs_to :delivery_order
  belongs_to :customer, class_name: "User"
  belongs_to :driver, class_name: "User", optional: true

  has_one :driver_earning, dependent: :destroy

  # Enums
  enum :status, {
    pending: 0,
    authorized: 1,
    captured: 2,
    refunded: 3,
    voided: 4,
    failed: 5
  }, prefix: true

  # Validations
  validates :delivery_order, presence: true
  validates :customer, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :currency, presence: true
  validates :status, presence: true
  validates :gateway_provider, presence: true
  validates :idempotency_key, uniqueness: true, allow_nil: true

  # Scopes
  scope :authorized, -> { where(status: :authorized) }
  scope :captured, -> { where(status: :captured) }
  scope :refunded, -> { where(status: :refunded) }
  scope :pending_capture, -> { where(status: :authorized).where("authorized_at < ?", 7.days.ago) }

  # Methods
  def amount_dollars
    (amount_cents / 100.0).round(2)
  end

  def authorize!(gateway_payment_id:, metadata: {})
    update!(
      status: :authorized,
      gateway_payment_id: gateway_payment_id,
      authorized_at: Time.current,
      metadata: self.metadata.merge(metadata)
    )
  end

  def capture!(metadata: {})
    update!(
      status: :captured,
      captured_at: Time.current,
      metadata: self.metadata.merge(metadata)
    )
  end

  def refund!(metadata: {})
    update!(
      status: :refunded,
      refunded_at: Time.current,
      metadata: self.metadata.merge(metadata)
    )
  end

  def mark_failed!(metadata: {})
    update!(
      status: :failed,
      metadata: self.metadata.merge(metadata)
    )
  end
end
