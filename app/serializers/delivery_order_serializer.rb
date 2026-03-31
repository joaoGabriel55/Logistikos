# frozen_string_literal: true

class DeliveryOrderSerializer
  def initialize(delivery_order)
    @order = delivery_order
  end

  def as_json
    {
      id: @order.id,
      tracking_code: @order.tracking_code,
      status: @order.status,
      delivery_type: @order.delivery_type,
      pickup_address: @order.pickup_address,
      dropoff_address: @order.dropoff_address,
      description: @order.description,
      suggested_price_cents: @order.suggested_price_cents,
      scheduled_at: @order.scheduled_at&.iso8601,
      order_items: order_items_data,
      pickup_location: location_data(@order.pickup_location),
      dropoff_location: location_data(@order.dropoff_location),
      estimated_distance_meters: @order.estimated_distance_meters,
      estimated_duration_seconds: @order.estimated_duration_seconds,
      estimated_price: @order.estimated_price,
      price: @order.price,
      created_at: @order.created_at.iso8601,
      updated_at: @order.updated_at.iso8601,
      creator: creator_data
    }
  end

  private

  def order_items_data
    @order.order_items.map do |item|
      {
        id: item.id,
        name: item.name,
        quantity: item.quantity,
        size: item.size
      }
    end
  end

  def location_data(location)
    return nil unless location

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    point = factory.parse_wkt(location.as_text)

    {
      type: "Point",
      coordinates: [ point.x, point.y ], # [lng, lat]
      latitude: point.y,
      longitude: point.x
    }
  end

  def creator_data
    return nil unless @order.creator

    {
      id: @order.creator.id,
      name: @order.creator.name,
      email: @order.creator.email
    }
  end
end
