class CreateDriverEarnings < ActiveRecord::Migration[8.1]
  def change
    create_table :driver_earnings do |t|
      t.references :driver, null: false, foreign_key: { to_table: :users }
      t.references :payment, null: false, foreign_key: true
      t.references :delivery_order, null: false, foreign_key: true

      # All amounts in cents to avoid floating-point errors
      t.integer :gross_amount_cents, null: false
      t.integer :platform_fee_cents, null: false
      t.integer :net_amount_cents, null: false

      # Payout tracking
      t.datetime :paid_out_at

      t.timestamps
    end

    add_index :driver_earnings, :paid_out_at
  end
end
