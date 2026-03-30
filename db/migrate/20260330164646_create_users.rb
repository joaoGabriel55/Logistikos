class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0

      # OAuth fields for Google authentication
      t.string :provider
      t.string :uid

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [ :provider, :uid ], unique: true, where: "provider IS NOT NULL AND uid IS NOT NULL"
  end
end
