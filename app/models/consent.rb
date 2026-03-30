class Consent < ApplicationRecord
  belongs_to :user

  # Enums
  enum :purpose, {
    terms_of_service: 0,
    location_tracking: 1,
    payment_processing: 2,
    marketing: 3
  }, prefix: true

  # Validations
  validates :user, presence: true
  validates :purpose, presence: true
  validate :either_granted_or_revoked

  # Scopes
  scope :granted, -> { where.not(granted_at: nil).where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  # Methods
  def granted?
    granted_at.present? && revoked_at.nil?
  end

  def revoked?
    revoked_at.present?
  end

  # Class methods
  def self.current_consent(user_id, purpose)
    where(user_id: user_id, purpose: purpose)
      .order(created_at: :desc)
      .first
  end

  def self.user_has_consent?(user_id, purpose)
    consent = current_consent(user_id, purpose)
    consent&.granted? || false
  end

  def self.grant_consent(user:, purpose:, ip_address: nil, user_agent: nil)
    create!(
      user: user,
      purpose: purpose,
      granted_at: Time.current,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def self.revoke_consent(user:, purpose:, ip_address: nil, user_agent: nil)
    create!(
      user: user,
      purpose: purpose,
      revoked_at: Time.current,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  private

  def either_granted_or_revoked
    if granted_at.nil? && revoked_at.nil?
      errors.add(:base, "Must have either granted_at or revoked_at set")
    end

    if granted_at.present? && revoked_at.present?
      errors.add(:base, "Cannot have both granted_at and revoked_at set")
    end
  end
end
