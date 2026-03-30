class CreateConnectedServices < ActiveRecord::Migration[8.1]
  def change
    create_table :connected_services do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end

    # Ensure each provider + uid combination is unique (can't connect same Google account twice)
    add_index :connected_services, [ :provider, :uid ], unique: true
  end
end
