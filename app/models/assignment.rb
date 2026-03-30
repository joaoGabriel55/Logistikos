class Assignment < ApplicationRecord
  belongs_to :delivery_order
  belongs_to :driver, class_name: "User"

  # Validations
  validates :delivery_order_id, presence: true, uniqueness: true
  validates :driver_id, presence: true
  validates :accepted_at, presence: true

  # Scopes
  scope :active, -> { joins(:delivery_order).where(delivery_orders: { status: [ :accepted, :pickup_in_progress, :in_transit ] }) }
  scope :with_stale_location, -> { where(location_stale: true) }

  # Methods
  def driver_coordinates
    return nil unless driver_location

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    point = factory.parse_wkt(driver_location.as_text)
    [ point.x, point.y ]
  end

  def update_driver_location(lat, lng)
    # Validate inputs to prevent SQL injection
    lat_f = Float(lat)
    lng_f = Float(lng)
    raise ArgumentError, "Invalid coordinates" unless lat_f.finite? && lng_f.finite?
    raise ArgumentError, "Latitude must be between -90 and 90" unless lat_f.between?(-90, 90)
    raise ArgumentError, "Longitude must be between -180 and 180" unless lng_f.between?(-180, 180)

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    self.driver_location = factory.point(lng_f, lat_f)
    self.last_location_updated_at = Time.current
    self.location_stale = false
  end

  def location_stale?
    return true if last_location_updated_at.nil?

    last_location_updated_at < 60.seconds.ago
  end

  def mark_location_stale!
    update!(location_stale: true)
  end
end
