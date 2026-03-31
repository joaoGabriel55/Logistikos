# frozen_string_literal: true

FactoryBot.define do
  factory :driver_profile do
    association :user, factory: [ :user, :driver ]
    vehicle_type { :car }
    is_available { false }
    radius_preference { 10_000 } # 10km in meters

    trait :available do
      is_available { true }
    end

    trait :with_location do
      after(:build) do |profile|
        # Set location to downtown coordinates (example: San Francisco)
        profile.set_location(37.7749, -122.4194)
      end
    end

    trait :motorcycle do
      vehicle_type { :motorcycle }
    end

    trait :car do
      vehicle_type { :car }
    end

    trait :van do
      vehicle_type { :van }
    end

    trait :truck do
      vehicle_type { :truck }
    end

    trait :with_large_radius do
      radius_preference { 50_000 } # 50km in meters
    end

    trait :with_small_radius do
      radius_preference { 5_000 } # 5km in meters
    end
  end
end
