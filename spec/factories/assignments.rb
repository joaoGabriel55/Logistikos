# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    association :delivery_order, factory: [ :delivery_order, :with_items ]
    association :driver, factory: [ :user, :driver ]
    accepted_at { Time.current }

    trait :with_location do
      after(:create) do |assignment|
        # San Francisco coordinates
        factory = RGeo::Geographic.spherical_factory(srid: 4326)
        assignment.driver_location = factory.point(-122.4194, 37.7749)
        assignment.last_location_updated_at = Time.current
        assignment.save!
      end
    end

    trait :stale_location do
      after(:create) do |assignment|
        factory = RGeo::Geographic.spherical_factory(srid: 4326)
        assignment.driver_location = factory.point(-122.4194, 37.7749)
        assignment.last_location_updated_at = 20.minutes.ago
        assignment.location_stale = true
        assignment.save!
      end
    end
  end
end
