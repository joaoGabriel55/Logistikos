# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    association :delivery_order
    name { Faker::Commerce.product_name }
    quantity { rand(1..10) }
    size { OrderItem.sizes.keys.sample }

    trait :small do
      size { :small }
    end

    trait :medium do
      size { :medium }
    end

    trait :large do
      size { :large }
    end

    trait :bulk do
      size { :bulk }
    end
  end
end
