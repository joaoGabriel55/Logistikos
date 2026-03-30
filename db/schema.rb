# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_30_171059) do
  create_schema "topology"

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgrouting"
  enable_extension "postgis"
  enable_extension "postgis_raster"
  enable_extension "topology.postgis_topology"

  create_table "public.assignments", force: :cascade do |t|
    t.datetime "accepted_at", null: false
    t.integer "cached_eta_seconds"
    t.datetime "created_at", null: false
    t.bigint "delivery_order_id", null: false
    t.bigint "driver_id", null: false
    t.geography "driver_location", limit: {srid: 4326, type: "st_point", geographic: true}
    t.datetime "last_location_updated_at"
    t.boolean "location_stale", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_order_id"], name: "index_assignments_on_delivery_order_id", unique: true
    t.index ["driver_id"], name: "index_assignments_on_driver_id"
    t.index ["driver_location"], name: "index_assignments_on_driver_location", using: :gist
    t.index ["location_stale"], name: "index_assignments_on_location_stale"
  end

  create_table "public.consents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "granted_at"
    t.string "ip_address"
    t.integer "purpose", null: false
    t.datetime "revoked_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id", "purpose", "created_at"], name: "index_consents_on_user_id_and_purpose_and_created_at"
    t.index ["user_id"], name: "index_consents_on_user_id"
  end

  create_table "public.delivery_orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.integer "delivery_type", default: 0, null: false
    t.text "description"
    t.text "dropoff_address", null: false
    t.geography "dropoff_location", limit: {srid: 4326, type: "st_point", geographic: true}, null: false
    t.integer "estimated_distance_meters"
    t.integer "estimated_duration_seconds"
    t.integer "estimated_price"
    t.text "pickup_address", null: false
    t.geography "pickup_location", limit: {srid: 4326, type: "st_point", geographic: true}, null: false
    t.integer "price"
    t.geography "route_geometry", limit: {srid: 4326, type: "line_string", geographic: true}
    t.datetime "scheduled_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_delivery_orders_on_created_by_id"
    t.index ["delivery_type"], name: "index_delivery_orders_on_delivery_type"
    t.index ["dropoff_location"], name: "index_delivery_orders_on_dropoff_location", using: :gist
    t.index ["pickup_location"], name: "index_delivery_orders_on_pickup_location", using: :gist
    t.index ["route_geometry"], name: "index_delivery_orders_on_route_geometry", using: :gist
    t.index ["scheduled_at"], name: "index_delivery_orders_on_scheduled_at"
    t.index ["status"], name: "index_delivery_orders_on_status"
  end

  create_table "public.driver_earnings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "delivery_order_id", null: false
    t.bigint "driver_id", null: false
    t.integer "gross_amount_cents", null: false
    t.integer "net_amount_cents", null: false
    t.datetime "paid_out_at"
    t.bigint "payment_id", null: false
    t.integer "platform_fee_cents", null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_order_id"], name: "index_driver_earnings_on_delivery_order_id"
    t.index ["driver_id"], name: "index_driver_earnings_on_driver_id"
    t.index ["paid_out_at"], name: "index_driver_earnings_on_paid_out_at"
    t.index ["payment_id"], name: "index_driver_earnings_on_payment_id"
  end

  create_table "public.driver_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_available", default: false, null: false
    t.datetime "last_location_updated_at"
    t.geography "location", limit: {srid: 4326, type: "st_point", geographic: true}
    t.integer "radius_preference", default: 10000, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "vehicle_type", default: 0, null: false
    t.index ["is_available"], name: "index_driver_profiles_on_is_available"
    t.index ["location"], name: "index_driver_profiles_on_location", using: :gist
    t.index ["user_id"], name: "index_driver_profiles_on_user_id", unique: true
  end

  create_table "public.notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "delivery_order_id", null: false
    t.boolean "is_expired", default: false, null: false
    t.boolean "is_read", default: false, null: false
    t.text "message", null: false
    t.integer "notification_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["delivery_order_id"], name: "index_notifications_on_delivery_order_id"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["user_id", "is_read", "is_expired"], name: "index_notifications_on_user_id_and_is_read_and_is_expired"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "public.order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "delivery_order_id", null: false
    t.string "name", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "size", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_order_id"], name: "index_order_items_on_delivery_order_id"
  end

  create_table "public.payment_methods", force: :cascade do |t|
    t.string "card_brand"
    t.string "card_last_four"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "gateway_provider", null: false
    t.string "gateway_token", null: false
    t.boolean "is_default", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "is_default"], name: "index_payment_methods_on_user_id_and_is_default"
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "public.payments", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "authorized_at"
    t.datetime "captured_at"
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.bigint "customer_id", null: false
    t.bigint "delivery_order_id", null: false
    t.bigint "driver_id"
    t.string "gateway_payment_id"
    t.string "gateway_provider", null: false
    t.string "idempotency_key"
    t.jsonb "metadata", default: {}
    t.datetime "refunded_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["delivery_order_id"], name: "index_payments_on_delivery_order_id"
    t.index ["driver_id"], name: "index_payments_on_driver_id"
    t.index ["gateway_payment_id"], name: "index_payments_on_gateway_payment_id", unique: true, where: "(gateway_payment_id IS NOT NULL)"
    t.index ["idempotency_key"], name: "index_payments_on_idempotency_key", unique: true, where: "(idempotency_key IS NOT NULL)"
    t.index ["metadata"], name: "index_payments_on_metadata", using: :gin
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "public.sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "public.users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "provider"
    t.integer "role", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "((provider IS NOT NULL) AND (uid IS NOT NULL))"
  end

  add_foreign_key "public.assignments", "public.delivery_orders"
  add_foreign_key "public.assignments", "public.users", column: "driver_id"
  add_foreign_key "public.consents", "public.users"
  add_foreign_key "public.delivery_orders", "public.users", column: "created_by_id"
  add_foreign_key "public.driver_earnings", "public.delivery_orders"
  add_foreign_key "public.driver_earnings", "public.payments"
  add_foreign_key "public.driver_earnings", "public.users", column: "driver_id"
  add_foreign_key "public.driver_profiles", "public.users"
  add_foreign_key "public.notifications", "public.delivery_orders"
  add_foreign_key "public.notifications", "public.users"
  add_foreign_key "public.order_items", "public.delivery_orders"
  add_foreign_key "public.payment_methods", "public.users"
  add_foreign_key "public.payments", "public.delivery_orders"
  add_foreign_key "public.payments", "public.users", column: "customer_id"
  add_foreign_key "public.payments", "public.users", column: "driver_id"
  add_foreign_key "public.sessions", "public.users"

end
