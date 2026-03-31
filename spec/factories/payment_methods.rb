# frozen_string_literal: true

FactoryBot.define do
  factory :payment_method do
    association :user
    gateway_provider { "mock" }
    gateway_token { "tok_#{SecureRandom.hex(16)}" }
    card_brand { [ "visa", "mastercard", "amex" ].sample }
    card_last_four { rand(1000..9999).to_s }
    is_default { false }
    expires_at { 1.year.from_now }

    trait :default do
      is_default { true }
    end

    trait :expired do
      expires_at { 1.month.ago }
    end

    trait :active do
      expires_at { 1.year.from_now }
    end
  end
end
