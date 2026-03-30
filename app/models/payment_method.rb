class PaymentMethod < ApplicationRecord
  belongs_to :user

  # Validations
  validates :user, presence: true
  validates :gateway_provider, presence: true
  validates :gateway_token, presence: true
  validate :only_one_default_per_user, if: :is_default?

  # PII encryption
  encrypts :gateway_token

  # Filter sensitive attributes from logs
  self.filter_attributes = %i[gateway_token]

  # Scopes
  scope :default, -> { where(is_default: true) }
  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  # Callbacks
  before_save :unset_other_defaults, if: :is_default?

  # Methods
  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def display_name
    return "Unknown Card" if card_brand.blank?

    "#{card_brand.titleize} •••• #{card_last_four}"
  end

  private

  def only_one_default_per_user
    if user.payment_methods.where(is_default: true).where.not(id: id).exists?
      errors.add(:is_default, "can only have one default payment method")
    end
  end

  def unset_other_defaults
    user.payment_methods.where.not(id: id).update_all(is_default: false)
  end
end
