module HasConsent
  extend ActiveSupport::Concern

  included do
    # Methods for checking and managing user consent
  end

  def has_consent?(purpose)
    Consent.user_has_consent?(id, purpose)
  end

  def grant_consent(purpose, ip_address: nil, user_agent: nil)
    Consent.grant_consent(
      user: self,
      purpose: purpose,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def revoke_consent(purpose, ip_address: nil, user_agent: nil)
    Consent.revoke_consent(
      user: self,
      purpose: purpose,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def current_consents
    Consent.purposes.keys.map do |purpose|
      consent = Consent.current_consent(id, purpose)
      {
        purpose: purpose,
        granted: consent&.granted? || false,
        timestamp: consent&.granted_at || consent&.revoked_at
      }
    end
  end
end
