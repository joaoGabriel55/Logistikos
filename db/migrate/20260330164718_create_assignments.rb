class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :delivery_order, null: false, foreign_key: true, index: { unique: true }
      t.references :driver, null: false, foreign_key: { to_table: :users }
      t.datetime :accepted_at, null: false

      # Real-time driver location tracking (PostGIS)
      t.st_point :driver_location, geographic: true, srid: 4326
      t.datetime :last_location_updated_at

      # Cached ETA for performance
      t.integer :cached_eta_seconds

      # Location staleness flag for monitoring
      t.boolean :location_stale, null: false, default: false

      t.timestamps
    end

    # GiST index for spatial queries
    add_index :assignments, :driver_location, using: :gist
    add_index :assignments, :location_stale
  end
end
