class CreateDriverProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :driver_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :vehicle_type, null: false, default: 0
      t.boolean :is_available, null: false, default: false
      t.integer :radius_preference, null: false, default: 10000 # meters

      # PostGIS spatial column for driver location (SRID 4326 = WGS84)
      t.st_point :location, geographic: true, srid: 4326
      t.datetime :last_location_updated_at

      t.timestamps
    end

    # GiST index for spatial queries (driver matching within radius)
    add_index :driver_profiles, :location, using: :gist
    add_index :driver_profiles, :is_available
  end
end
