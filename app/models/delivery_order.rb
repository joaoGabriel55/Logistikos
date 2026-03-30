class DeliveryOrder < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id

  has_many :order_items, dependent: :destroy
  has_one :assignment, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :payment, dependent: :restrict_with_error

  # Enums
  enum :status, {
    processing: 0,
    open: 1,
    accepted: 2,
    pickup_in_progress: 3,
    in_transit: 4,
    completed: 5,
    cancelled: 6,
    expired: 7,
    error: 8
  }, prefix: true

  enum :delivery_type, { immediate: 0, scheduled: 1 }, prefix: true

  # Validations
  validates :creator, presence: true
  validates :status, presence: true
  validates :delivery_type, presence: true
  validates :pickup_address, presence: true
  validates :dropoff_address, presence: true

  # Encrypt addresses at rest
  encrypts :pickup_address
  encrypts :dropoff_address
  encrypts :description

  # Filter sensitive attributes from logs
  self.filter_attributes = %i[pickup_address dropoff_address description]

  # Scopes
  scope :open_orders, -> { where(status: :open) }
  scope :active_deliveries, -> { where(status: [ :accepted, :pickup_in_progress, :in_transit ]) }
  scope :completed, -> { where(status: :completed) }
  scope :immediate, -> { where(delivery_type: :immediate) }
  scope :scheduled_for, ->(time_range) { where(scheduled_at: time_range) }

  scope :near_pickup, ->(lat, lng, radius_meters) {
    where(
      "ST_DWithin(pickup_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)",
      lng, lat, radius_meters
    )
  }

  # Methods
  def assigned?
    assignment.present?
  end

  def driver
    assignment&.driver
  end

  def pickup_coordinates
    return nil unless pickup_location

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    point = factory.parse_wkt(pickup_location.as_text)
    [ point.x, point.y ]
  end

  def dropoff_coordinates
    return nil unless dropoff_location

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    point = factory.parse_wkt(dropoff_location.as_text)
    [ point.x, point.y ]
  end

  def set_pickup_location(lat, lng)
    # Validate inputs to prevent SQL injection
    lat_f = Float(lat)
    lng_f = Float(lng)
    raise ArgumentError, "Invalid coordinates" unless lat_f.finite? && lng_f.finite?
    raise ArgumentError, "Latitude must be between -90 and 90" unless lat_f.between?(-90, 90)
    raise ArgumentError, "Longitude must be between -180 and 180" unless lng_f.between?(-180, 180)

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    self.pickup_location = factory.point(lng_f, lat_f)
  end

  def set_dropoff_location(lat, lng)
    # Validate inputs to prevent SQL injection
    lat_f = Float(lat)
    lng_f = Float(lng)
    raise ArgumentError, "Invalid coordinates" unless lat_f.finite? && lng_f.finite?
    raise ArgumentError, "Latitude must be between -90 and 90" unless lat_f.between?(-90, 90)
    raise ArgumentError, "Longitude must be between -180 and 180" unless lng_f.between?(-180, 180)

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    self.dropoff_location = factory.point(lng_f, lat_f)
  end

  def set_route_geometry(coordinates_array)
    # coordinates_array: array of [lng, lat] pairs
    # Validate each coordinate pair to prevent SQL injection
    factory = RGeo::Geographic.spherical_factory(srid: 4326)

    points = coordinates_array.map do |coord|
      lng_f = Float(coord[0])
      lat_f = Float(coord[1])
      raise ArgumentError, "Invalid coordinates" unless lng_f.finite? && lat_f.finite?
      raise ArgumentError, "Latitude must be between -90 and 90" unless lat_f.between?(-90, 90)
      raise ArgumentError, "Longitude must be between -180 and 180" unless lng_f.between?(-180, 180)

      factory.point(lng_f, lat_f)
    end

    self.route_geometry = factory.line_string(points)
  end
end
