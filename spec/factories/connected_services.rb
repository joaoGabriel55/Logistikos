FactoryBot.define do
  factory :connected_service do
    association :user
    provider { "google_oauth2" }
    sequence(:uid) { |n| "google_uid_#{n}" }

    trait :github do
      provider { "github" }
      sequence(:uid) { |n| "github_uid_#{n}" }
    end
  end
end
