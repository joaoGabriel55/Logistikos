class DriverEarning < ApplicationRecord
  belongs_to :driver, class_name: "User"
  belongs_to :payment
  belongs_to :delivery_order

  # Validations
  validates :driver, presence: true
  validates :payment, presence: true
  validates :delivery_order, presence: true
  validates :gross_amount_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :platform_fee_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :net_amount_cents, presence: true, numericality: { greater_than: 0, only_integer: true }

  # Scopes
  scope :unpaid, -> { where(paid_out_at: nil) }
  scope :paid, -> { where.not(paid_out_at: nil) }
  scope :for_driver, ->(driver_id) { where(driver_id: driver_id) }
  scope :in_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Methods
  def gross_amount_dollars
    (gross_amount_cents / 100.0).round(2)
  end

  def platform_fee_dollars
    (platform_fee_cents / 100.0).round(2)
  end

  def net_amount_dollars
    (net_amount_cents / 100.0).round(2)
  end

  def paid?
    paid_out_at.present?
  end

  def mark_paid!
    update!(paid_out_at: Time.current)
  end

  # Calculate platform fee based on gross amount
  def self.calculate_platform_fee(gross_amount_cents, platform_fee_percent = 15)
    (gross_amount_cents * platform_fee_percent / 100.0).round
  end

  # Calculate net amount after platform fee
  def self.calculate_net_amount(gross_amount_cents, platform_fee_cents)
    gross_amount_cents - platform_fee_cents
  end
end
