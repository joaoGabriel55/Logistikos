class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :delivery_order, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :driver, foreign_key: { to_table: :users }

      # Amount in cents to avoid floating-point errors
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: "USD"

      # Payment lifecycle status
      t.integer :status, null: false, default: 0

      # Gateway information
      t.string :gateway_provider, null: false
      t.string :gateway_payment_id

      # Timestamps for audit trail
      t.datetime :authorized_at
      t.datetime :captured_at
      t.datetime :refunded_at

      # Flexible metadata storage for gateway-specific data
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :payments, :status
    add_index :payments, :gateway_payment_id, unique: true, where: "gateway_payment_id IS NOT NULL"
    add_index :payments, :metadata, using: :gin
  end
end
