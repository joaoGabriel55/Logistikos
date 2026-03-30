class CreateDeliveryOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_orders do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.integer :delivery_type, null: false, default: 0

      # Address information (will be encrypted at model level)
      t.text :pickup_address, null: false
      t.text :dropoff_address, null: false
      t.text :description

      # PostGIS spatial columns (SRID 4326 = WGS84)
      t.st_point :pickup_location, geographic: true, srid: 4326, null: false
      t.st_point :dropoff_location, geographic: true, srid: 4326, null: false
      t.line_string :route_geometry, geographic: true, srid: 4326

      # Calculated route information
      t.integer :estimated_distance_meters
      t.integer :estimated_duration_seconds

      # Pricing
      t.integer :price # Final price in cents
      t.integer :estimated_price # AI-estimated price in cents

      # Scheduling
      t.datetime :scheduled_at

      t.timestamps
    end

    # Indexes for common queries
    add_index :delivery_orders, :status
    add_index :delivery_orders, :delivery_type
    add_index :delivery_orders, :scheduled_at

    # GiST indexes for spatial queries
    add_index :delivery_orders, :pickup_location, using: :gist
    add_index :delivery_orders, :dropoff_location, using: :gist
    add_index :delivery_orders, :route_geometry, using: :gist
  end
end
