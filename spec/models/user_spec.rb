# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user, :customer) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }

    it "validates email format" do
      user = build(:user, email: "invalid_email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "validates email uniqueness" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "validates password presence for new users" do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "validates password minimum length" do
      user = build(:user, password: "short")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:driver_profile).dependent(:destroy) }
    it { is_expected.to have_many(:delivery_orders).with_foreign_key(:created_by_id).dependent(:destroy) }
    it { is_expected.to have_many(:payment_methods).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:consents).dependent(:destroy) }
    it { is_expected.to have_many(:connected_services).dependent(:destroy) }
    it { is_expected.to have_many(:assignments).with_foreign_key(:driver_id) }
    it { is_expected.to have_many(:driver_earnings).with_foreign_key(:driver_id) }
    it { is_expected.to have_many(:payments).with_foreign_key(:customer_id) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(customer: 0, driver: 1).with_prefix(:role) }
  end

  describe "scopes" do
    let!(:customer1) { create(:user, :customer) }
    let!(:customer2) { create(:user, :customer) }
    let!(:driver1) { create(:user, :driver) }
    let!(:driver2) { create(:user, :driver) }

    it "returns only customers" do
      expect(User.customers).to match_array([ customer1, customer2 ])
    end

    it "returns only drivers" do
      expect(User.drivers).to match_array([ driver1, driver2 ])
    end
  end

  describe "#customer?" do
    it "returns true for customer role" do
      user = build(:user, :customer)
      expect(user.customer?).to be true
    end

    it "returns false for driver role" do
      user = build(:user, :driver)
      expect(user.customer?).to be false
    end
  end

  describe "#driver?" do
    it "returns true for driver role" do
      user = build(:user, :driver)
      expect(user.driver?).to be true
    end

    it "returns false for customer role" do
      user = build(:user, :customer)
      expect(user.driver?).to be false
    end
  end

  describe "OAuth via connected_services" do
    it "allows users to have multiple OAuth providers" do
      user = create(:user, :customer)

      google_service = create(:connected_service, user: user, provider: "google_oauth2", uid: "google123")
      github_service = create(:connected_service, user: user, provider: "github", uid: "github456")

      expect(user.connected_services).to contain_exactly(google_service, github_service)
    end
  end

  describe "encryption" do
    it "encrypts the name field" do
      user = create(:user, name: "Test User")
      encrypted_name = user.attributes_before_type_cast["name"]

      # The encrypted value should be different from the plaintext
      expect(encrypted_name).not_to eq("Test User")
    end

    it "encrypts the email field deterministically" do
      user1 = create(:user, email: "test@example.com")
      user2 = create(:user, email: "test2@example.com")

      # The email should be readable (decrypted automatically)
      expect(user1.email).to eq("test@example.com")
      expect(user2.email).to eq("test2@example.com")

      # But the raw attributes should be encrypted
      raw_email_1 = ActiveRecord::Base.connection.select_value("SELECT email FROM users WHERE id = #{user1.id}")
      expect(raw_email_1).not_to eq("test@example.com")
      expect(raw_email_1).to include("{") # Encrypted JSON format
    end
  end

  describe "password authentication" do
    let(:user) { create(:user, password: "password123") }

    it "authenticates with correct password" do
      expect(user.authenticate("password123")).to eq(user)
    end

    it "does not authenticate with incorrect password" do
      expect(user.authenticate("wrongpassword")).to be false
    end
  end

  describe "PII filtering" do
    it "filters sensitive attributes from logs" do
      expect(User.filter_attributes).to include(:name, :email, :password_digest)
    end
  end
end
