class ModifyDeliveryOrdersForOrderCreation < ActiveRecord::Migration[8.1]
  def change
    # Make location columns nullable since orders start in processing state without geocoding
    change_column_null :delivery_orders, :pickup_location, true
    change_column_null :delivery_orders, :dropoff_location, true

    # Add tracking_code column for customer-facing order identifiers
    add_column :delivery_orders, :tracking_code, :string
    add_index :delivery_orders, :tracking_code, unique: true

    # Add suggested_price_cents column for customer price suggestions
    add_column :delivery_orders, :suggested_price_cents, :integer
  end
end
