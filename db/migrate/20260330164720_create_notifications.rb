class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :delivery_order, null: false, foreign_key: true
      t.integer :notification_type, null: false
      t.text :message, null: false

      t.boolean :is_read, null: false, default: false
      t.boolean :is_expired, null: false, default: false

      t.timestamps
    end

    # Compound index for efficient unread notification queries
    add_index :notifications, [ :user_id, :is_read, :is_expired ]
    add_index :notifications, :notification_type
  end
end
