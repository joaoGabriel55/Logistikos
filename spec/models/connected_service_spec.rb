require 'rails_helper'

RSpec.describe ConnectedService, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:uid) }

    it "validates uniqueness of uid scoped to provider" do
      user = create(:user, :customer)
      create(:connected_service, user: user, provider: "google_oauth2", uid: "12345")

      duplicate = build(:connected_service, user: user, provider: "google_oauth2", uid: "12345")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:uid]).to include("has already been taken")
    end

    it "allows same uid for different providers" do
      user = create(:user, :customer)
      create(:connected_service, user: user, provider: "google_oauth2", uid: "12345")

      different_provider = build(:connected_service, user: user, provider: "github", uid: "12345")
      expect(different_provider).to be_valid
    end
  end

  describe "database constraints" do
    it "enforces unique index on provider and uid combination" do
      user1 = create(:user, :customer)
      user2 = create(:user, :driver)

      create(:connected_service, user: user1, provider: "google_oauth2", uid: "12345")

      expect {
        create(:connected_service, user: user2, provider: "google_oauth2", uid: "12345")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
