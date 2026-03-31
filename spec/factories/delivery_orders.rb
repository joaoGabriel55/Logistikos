# frozen_string_literal: true

FactoryBot.define do
  factory :delivery_order do
    association :creator, factory: [ :user, :customer ]
    status { :processing }
    delivery_type { :immediate }
    pickup_address { Faker::Address.full_address }
    dropoff_address { Faker::Address.full_address }
    tracking_code { "DEL-#{SecureRandom.alphanumeric(6).upcase}" }

    trait :scheduled do
      delivery_type { :scheduled }
      scheduled_at { 2.hours.from_now }
    end

    trait :with_items do
      after(:build) do |order|
        order.order_items << build(:order_item, delivery_order: nil)
        order.order_items << build(:order_item, delivery_order: nil)
      end
    end

    trait :with_location do
      after(:create) do |order|
        # San Francisco coordinates
        order.set_pickup_location(37.7749, -122.4194)
        order.set_dropoff_location(37.8044, -122.2712)
        order.save!
      end
    end

    trait :with_description do
      description { Faker::Lorem.sentence }
    end

    trait :with_suggested_price do
      suggested_price_cents { rand(500..5000) }
    end
  end
end
