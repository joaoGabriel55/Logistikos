class CreateConsents < ActiveRecord::Migration[8.1]
  def change
    create_table :consents do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :purpose, null: false

      # Audit trail (append-only, never update)
      t.datetime :granted_at
      t.datetime :revoked_at

      # Context for compliance
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    # Index for finding current consent state
    add_index :consents, [ :user_id, :purpose, :created_at ]
  end
end
