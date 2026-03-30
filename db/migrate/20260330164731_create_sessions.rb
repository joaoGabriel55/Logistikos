class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      # Rails 8 authentication uses created_at, not updated_at
      t.datetime :created_at, null: false
    end
  end
end
