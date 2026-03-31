# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriverProfile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:vehicle_type)
        .with_values(motorcycle: 0, car: 1, van: 2, truck: 3)
        .with_prefix(:vehicle_type)
    }
  end

  describe "validations" do
    subject { build(:driver_profile) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_uniqueness_of(:user_id) }
    it { is_expected.to validate_presence_of(:vehicle_type) }

    it "validates radius_preference is greater than 0" do
      profile = build(:driver_profile, radius_preference: 0)
      expect(profile).not_to be_valid
      expect(profile.errors[:radius_preference]).to include("must be greater than 0")
    end

    it "validates radius_preference is not negative" do
      profile = build(:driver_profile, radius_preference: -100)
      expect(profile).not_to be_valid
      expect(profile.errors[:radius_preference]).to include("must be greater than 0")
    end

    it "validates radius_preference does not exceed 50km (50000 meters)" do
      profile = build(:driver_profile, radius_preference: 50_001)
      expect(profile).not_to be_valid
      expect(profile.errors[:radius_preference]).to include("must be less than or equal to 50000")
    end

    it "allows radius_preference at exactly 50km (50000 meters)" do
      driver = create(:user, :driver)
      profile = build(:driver_profile, user: driver, radius_preference: 50_000)
      expect(profile).to be_valid
    end
  end

  describe "scopes" do
    let!(:available_driver1) { create(:driver_profile, :available, :with_location) }
    let!(:available_driver2) { create(:driver_profile, :available, :with_location) }
    let!(:unavailable_driver) { create(:driver_profile, :with_location, is_available: false) }

    describe ".available" do
      it "returns only available drivers" do
        expect(DriverProfile.available).to match_array([ available_driver1, available_driver2 ])
      end

      it "excludes unavailable drivers" do
        expect(DriverProfile.available).not_to include(unavailable_driver)
      end
    end

    describe ".within_radius" do
      let(:center_lat) { 37.7749 }
      let(:center_lng) { -122.4194 }
      let(:close_driver) { create(:driver_profile, :with_location) }
      let(:far_driver) { create(:driver_profile) }

      before do
        # Set close driver to exactly the center point
        close_driver.set_location(center_lat, center_lng)
        close_driver.save!

        # Set far driver to ~20km away (rough calculation)
        far_driver.set_location(center_lat + 0.2, center_lng + 0.2)
        far_driver.save!
      end

      # Note: These tests require spatial_ref_sys to be populated in the test database
      # Run: docker exec logistikos-postgres-1 psql -U postgres -d logistikos_test -f /usr/share/postgresql/16/contrib/postgis-3.4/spatial_ref_sys.sql
      it "returns drivers within the specified radius", :skip_in_ci do
        # 10km radius should include close_driver but not far_driver
        results = DriverProfile.within_radius(center_lat, center_lng, 10_000)
        expect(results).to include(close_driver)
        expect(results).not_to include(far_driver)
      end

      it "returns drivers within a larger radius", :skip_in_ci do
        # 50km radius should include both
        results = DriverProfile.within_radius(center_lat, center_lng, 50_000)
        expect(results).to include(close_driver)
        expect(results).to include(far_driver)
      end
    end
  end

  describe "#available?" do
    it "returns true when is_available is true" do
      profile = build(:driver_profile, is_available: true)
      expect(profile.available?).to be true
    end

    it "returns false when is_available is false" do
      profile = build(:driver_profile, is_available: false)
      expect(profile.available?).to be false
    end
  end

  describe "#location_stale?" do
    it "returns true when last_location_updated_at is nil" do
      profile = build(:driver_profile, last_location_updated_at: nil)
      expect(profile.location_stale?).to be true
    end

    it "returns true when last_location_updated_at is older than 60 seconds" do
      profile = build(:driver_profile, last_location_updated_at: 61.seconds.ago)
      expect(profile.location_stale?).to be true
    end

    it "returns false when last_location_updated_at is within 60 seconds" do
      profile = build(:driver_profile, last_location_updated_at: 30.seconds.ago)
      expect(profile.location_stale?).to be false
    end
  end

  describe "#coordinates" do
    it "returns nil when location is not set" do
      profile = build(:driver_profile)
      expect(profile.coordinates).to be_nil
    end

    it "returns [lng, lat] array when location is set" do
      profile = build(:driver_profile)
      profile.set_location(37.7749, -122.4194)
      coords = profile.coordinates

      expect(coords).to be_an(Array)
      expect(coords.size).to eq(2)
      expect(coords[0]).to be_within(0.0001).of(-122.4194) # longitude
      expect(coords[1]).to be_within(0.0001).of(37.7749)   # latitude
    end
  end

  describe "#set_location" do
    let(:profile) { build(:driver_profile) }

    it "sets location as PostGIS Point with SRID 4326" do
      profile.set_location(37.7749, -122.4194)
      expect(profile.location).not_to be_nil
      expect(profile.location.srid).to eq(4326)
    end

    it "updates last_location_updated_at" do
      profile.set_location(37.7749, -122.4194)
      expect(profile.last_location_updated_at).to be_within(1.second).of(Time.current)
    end

    it "raises ArgumentError for invalid latitude (> 90)" do
      expect {
        profile.set_location(91, -122.4194)
      }.to raise_error(ArgumentError, "Latitude must be between -90 and 90")
    end

    it "raises ArgumentError for invalid latitude (< -90)" do
      expect {
        profile.set_location(-91, -122.4194)
      }.to raise_error(ArgumentError, "Latitude must be between -90 and 90")
    end

    it "raises ArgumentError for invalid longitude (> 180)" do
      expect {
        profile.set_location(37.7749, 181)
      }.to raise_error(ArgumentError, "Longitude must be between -180 and 180")
    end

    it "raises ArgumentError for invalid longitude (< -180)" do
      expect {
        profile.set_location(37.7749, -181)
      }.to raise_error(ArgumentError, "Longitude must be between -180 and 180")
    end

    it "raises ArgumentError for non-numeric coordinates" do
      expect {
        profile.set_location("invalid", -122.4194)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#radius_preference_km" do
    it "converts meters to kilometers" do
      profile = build(:driver_profile, radius_preference: 10_000)
      expect(profile.radius_preference_km).to eq(10.0)
    end

    it "rounds to one decimal place" do
      profile = build(:driver_profile, radius_preference: 15_500)
      expect(profile.radius_preference_km).to eq(15.5)
    end
  end

  describe "#radius_preference_km=" do
    it "converts kilometers to meters" do
      profile = build(:driver_profile)
      profile.radius_preference_km = 20.0
      expect(profile.radius_preference).to eq(20_000)
    end

    it "handles decimal kilometer values" do
      profile = build(:driver_profile)
      profile.radius_preference_km = 12.5
      expect(profile.radius_preference).to eq(12_500)
    end
  end

  describe "PostGIS integration" do
    it "stores location as geography type with SRID 4326" do
      profile = create(:driver_profile, :with_location)
      profile.reload

      # Verify the data type in the database
      raw_location = ActiveRecord::Base.connection.select_value(
        "SELECT ST_AsText(location) FROM driver_profiles WHERE id = #{profile.id}"
      )

      expect(raw_location).to match(/POINT\(-122\.4194 37\.7749\)/)
    end

    # Note: This test requires spatial_ref_sys to be populated in the test database
    it "uses ST_DWithin for spatial queries", :skip_in_ci do
      profile = create(:driver_profile, :with_location)

      # This tests that the scope works with PostGIS functions
      results = DriverProfile.within_radius(37.7749, -122.4194, 1000)
      expect(results).to include(profile)
    end
  end

  describe "vehicle type transitions" do
    it "allows changing vehicle type" do
      profile = create(:driver_profile, vehicle_type: :motorcycle)
      profile.update(vehicle_type: :truck)

      expect(profile.reload.vehicle_type).to eq("truck")
    end

    it "validates presence of vehicle type" do
      profile = build(:driver_profile, vehicle_type: nil)
      expect(profile).not_to be_valid
      expect(profile.errors[:vehicle_type]).to include("can't be blank")
    end
  end
end
