module Anonymizable
  extend ActiveSupport::Concern

  included do
    # Methods for GDPR/LGPD compliance - anonymize user PII data
  end

  def anonymize!
    anonymize_user_data
    save!
  end

  private

  def anonymize_user_data
    # Use SecureRandom to prevent enumeration attacks
    random_id = SecureRandom.hex(8)
    self.name = "Anonymous User #{random_id}"
    self.email = "user_#{random_id}@anonymized.local"
    self.password_digest = SecureRandom.hex(32)
  end
end
