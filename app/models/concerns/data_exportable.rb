module DataExportable
  extend ActiveSupport::Concern

  included do
    # Methods for GDPR/LGPD compliance - export user data
  end

  def export_data
    {
      user: {
        id: id,
        name: name,
        email: email,
        role: role,
        created_at: created_at,
        updated_at: updated_at
      },
      driver_profile: driver_profile&.as_json(except: [ :created_at, :updated_at ]),
      delivery_orders: delivery_orders.map { |order| order.as_json(except: [ :created_at, :updated_at ]) },
      payment_methods: payment_methods.map { |pm| pm.as_json(only: [ :card_brand, :card_last_four, :is_default, :expires_at ]) },
      consents: consents.map { |c| c.as_json(except: [ :id ]) }
    }
  end
end
