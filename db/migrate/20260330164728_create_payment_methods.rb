class CreatePaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true

      t.string :gateway_provider, null: false
      # Gateway token will be encrypted at model level
      t.string :gateway_token, null: false

      # Card display information (last 4 digits, brand)
      t.string :card_last_four
      t.string :card_brand

      t.boolean :is_default, null: false, default: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :payment_methods, [ :user_id, :is_default ]
  end
end
