# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryOrderSerializer, type: :serializer do
  let(:customer) { create(:user, :customer) }
  let(:order) { create(:delivery_order, :with_items, creator: customer) }

  describe "#as_json" do
    subject(:serialized_data) { described_class.new(order).as_json }

    it "includes order id" do
      expect(serialized_data[:id]).to eq(order.id)
    end

    it "includes tracking_code" do
      expect(serialized_data[:tracking_code]).to eq(order.tracking_code)
    end

    it "includes status" do
      expect(serialized_data[:status]).to eq(order.status)
    end

    it "includes delivery_type" do
      expect(serialized_data[:delivery_type]).to eq(order.delivery_type)
    end

    it "includes pickup_address" do
      expect(serialized_data[:pickup_address]).to eq(order.pickup_address)
    end

    it "includes dropoff_address" do
      expect(serialized_data[:dropoff_address]).to eq(order.dropoff_address)
    end

    it "includes description" do
      order_with_description = create(:delivery_order, :with_items, :with_description)
      serialized = described_class.new(order_with_description).as_json
      expect(serialized[:description]).to eq(order_with_description.description)
    end

    it "includes suggested_price_cents" do
      order_with_price = create(:delivery_order, :with_items, :with_suggested_price)
      serialized = described_class.new(order_with_price).as_json
      expect(serialized[:suggested_price_cents]).to eq(order_with_price.suggested_price_cents)
    end

    it "includes scheduled_at as ISO8601" do
      scheduled_order = create(:delivery_order, :with_items, :scheduled)
      serialized = described_class.new(scheduled_order).as_json
      expect(serialized[:scheduled_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    it "includes order_items array" do
      expect(serialized_data[:order_items]).to be_an(Array)
      expect(serialized_data[:order_items].length).to eq(order.order_items.count)
    end

    it "includes order item details" do
      first_item = serialized_data[:order_items].first
      original_item = order.order_items.first

      expect(first_item[:id]).to eq(original_item.id)
      expect(first_item[:name]).to eq(original_item.name)
      expect(first_item[:quantity]).to eq(original_item.quantity)
      expect(first_item[:size]).to eq(original_item.size)
    end

    it "includes timestamps as ISO8601" do
      expect(serialized_data[:created_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      expect(serialized_data[:updated_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    it "includes creator data" do
      expect(serialized_data[:creator]).to be_a(Hash)
      expect(serialized_data[:creator][:id]).to eq(customer.id)
      expect(serialized_data[:creator][:name]).to eq(customer.name)
      expect(serialized_data[:creator][:email]).to eq(customer.email)
    end

    context "with locations" do
      let(:order_with_location) { create(:delivery_order, :with_items, :with_location) }
      subject(:serialized_data) { described_class.new(order_with_location).as_json }

      it "includes pickup_location" do
        expect(serialized_data[:pickup_location]).to be_a(Hash)
        expect(serialized_data[:pickup_location][:type]).to eq("Point")
        expect(serialized_data[:pickup_location][:coordinates]).to be_an(Array)
        expect(serialized_data[:pickup_location][:latitude]).to be_a(Float)
        expect(serialized_data[:pickup_location][:longitude]).to be_a(Float)
      end

      it "includes dropoff_location" do
        expect(serialized_data[:dropoff_location]).to be_a(Hash)
        expect(serialized_data[:dropoff_location][:type]).to eq("Point")
        expect(serialized_data[:dropoff_location][:coordinates]).to be_an(Array)
      end
    end

    context "without locations" do
      it "returns nil for pickup_location" do
        expect(serialized_data[:pickup_location]).to be_nil
      end

      it "returns nil for dropoff_location" do
        expect(serialized_data[:dropoff_location]).to be_nil
      end
    end

    it "includes estimated_distance_meters" do
      expect(serialized_data).to have_key(:estimated_distance_meters)
    end

    it "includes estimated_duration_seconds" do
      expect(serialized_data).to have_key(:estimated_duration_seconds)
    end

    it "includes estimated_price" do
      expect(serialized_data).to have_key(:estimated_price)
    end

    it "includes price" do
      expect(serialized_data).to have_key(:price)
    end
  end
end
