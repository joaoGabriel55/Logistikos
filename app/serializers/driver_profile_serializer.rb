# frozen_string_literal: true

class DriverProfileSerializer
  def initialize(driver_profile)
    @driver_profile = driver_profile
  end

  def as_json
    {
      id: @driver_profile.id,
      user_id: @driver_profile.user_id,
      vehicle_type: @driver_profile.vehicle_type,
      is_available: @driver_profile.is_available,
      radius_preference_km: @driver_profile.radius_preference_km,
      location: location_data,
      last_location_updated_at: @driver_profile.last_location_updated_at&.iso8601,
      location_stale: @driver_profile.location_stale?,
      created_at: @driver_profile.created_at.iso8601,
      updated_at: @driver_profile.updated_at.iso8601
    }
  end

  private

  def location_data
    return nil unless @driver_profile.location

    coordinates = @driver_profile.coordinates
    {
      type: "Point",
      coordinates: coordinates, # [lng, lat]
      latitude: coordinates[1],
      longitude: coordinates[0]
    }
  end
end
