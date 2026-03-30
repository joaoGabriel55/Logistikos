class DriverProfile < ApplicationRecord
  belongs_to :user

  # Enums
  enum :vehicle_type, { motorcycle: 0, car: 1, van: 2, truck: 3 }, prefix: true

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :vehicle_type, presence: true
  validates :radius_preference, numericality: { greater_than: 0 }

  # Scopes
  scope :available, -> { where(is_available: true) }
  scope :within_radius, ->(lat, lng, radius_meters) {
    where(
      "ST_DWithin(location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
      lng, lat, radius_meters
    )
  }

  # Methods
  def available?
    is_available
  end

  def location_stale?
    return true if last_location_updated_at.nil?

    last_location_updated_at < 60.seconds.ago
  end

  def coordinates
    return nil unless location

    # Convert PostGIS point to [lng, lat]
    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    point = factory.parse_wkt(location.as_text)
    [ point.x, point.y ]
  end

  def set_location(lat, lng)
    # Validate inputs to prevent SQL injection
    lat_f = Float(lat)
    lng_f = Float(lng)
    raise ArgumentError, "Invalid coordinates" unless lat_f.finite? && lng_f.finite?
    raise ArgumentError, "Latitude must be between -90 and 90" unless lat_f.between?(-90, 90)
    raise ArgumentError, "Longitude must be between -180 and 180" unless lng_f.between?(-180, 180)

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    self.location = factory.point(lng_f, lat_f)
    self.last_location_updated_at = Time.current
  end
end
