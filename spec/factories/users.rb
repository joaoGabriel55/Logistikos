# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
    password { "password123" }
    password_confirmation { "password123" }
    role { :customer }

    trait :customer do
      role { :customer }
    end

    trait :driver do
      role { :driver }
    end

    trait :with_oauth do
      after(:create) do |user|
        create(:connected_service, user: user)
      end
      password_digest { BCrypt::Password.create(SecureRandom.hex(32)) }
    end
  end
end
