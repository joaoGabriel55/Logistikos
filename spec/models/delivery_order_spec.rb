# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryOrder, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:creator).class_name("User").with_foreign_key(:created_by_id) }
    it { is_expected.to have_many(:order_items).dependent(:destroy) }
    it { is_expected.to have_one(:assignment).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_one(:payment) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(
          processing: 0,
          open: 1,
          accepted: 2,
          pickup_in_progress: 3,
          in_transit: 4,
          completed: 5,
          cancelled: 6,
          expired: 7,
          error: 8
        )
        .with_prefix(:status)
    }

    it {
      is_expected.to define_enum_for(:delivery_type)
        .with_values(immediate: 0, scheduled: 1)
        .with_prefix(:delivery_type)
    }
  end

  describe "validations" do
    subject { build(:delivery_order, :with_items) }

    it { is_expected.to validate_presence_of(:creator) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:delivery_type) }
    it { is_expected.to validate_presence_of(:pickup_address) }
    it { is_expected.to validate_presence_of(:dropoff_address) }

    it "validates pickup_address minimum length" do
      order = build(:delivery_order, :with_items, pickup_address: "abc")
      expect(order).not_to be_valid
      expect(order.errors[:pickup_address]).to be_present
    end

    it "validates dropoff_address minimum length" do
      order = build(:delivery_order, :with_items, dropoff_address: "xyz")
      expect(order).not_to be_valid
      expect(order.errors[:dropoff_address]).to be_present
    end

    it "validates description maximum length" do
      order = build(:delivery_order, :with_items, description: "a" * 501)
      expect(order).not_to be_valid
      expect(order.errors[:description]).to be_present
    end

    it "allows description up to 500 characters" do
      order = build(:delivery_order, :with_items, description: "a" * 500)
      expect(order).to be_valid
    end

    it "validates suggested_price_cents is positive" do
      order = build(:delivery_order, :with_items, suggested_price_cents: -100)
      expect(order).not_to be_valid
      expect(order.errors[:suggested_price_cents]).to be_present
    end

    it "allows nil suggested_price_cents" do
      order = build(:delivery_order, :with_items, suggested_price_cents: nil)
      expect(order).to be_valid
    end

    context "scheduled delivery" do
      it "requires scheduled_at for scheduled delivery type" do
        order = build(:delivery_order, :with_items, delivery_type: :scheduled, scheduled_at: nil)
        expect(order).not_to be_valid
        expect(order.errors[:scheduled_at]).to include("can't be blank")
      end

      it "does not require scheduled_at for immediate delivery" do
        order = build(:delivery_order, :with_items, delivery_type: :immediate, scheduled_at: nil)
        expect(order).to be_valid
      end

      it "validates scheduled_at is in the future" do
        order = build(:delivery_order, :with_items, delivery_type: :scheduled, scheduled_at: 1.hour.ago)
        expect(order).not_to be_valid
        expect(order.errors[:scheduled_at]).to include("must be in the future")
      end

      it "allows future scheduled_at" do
        order = build(:delivery_order, :with_items, delivery_type: :scheduled, scheduled_at: 1.hour.from_now)
        expect(order).to be_valid
      end
    end

    context "address validation" do
      it "validates pickup and dropoff are different" do
        order = build(:delivery_order, :with_items, pickup_address: "123 Main St", dropoff_address: "123 Main St")
        expect(order).not_to be_valid
        expect(order.errors[:dropoff_address]).to include("must be different from pickup address")
      end

      it "allows different addresses" do
        order = build(:delivery_order, :with_items, pickup_address: "123 Main St", dropoff_address: "456 Oak Ave")
        expect(order).to be_valid
      end
    end

    context "order items validation" do
      it "validates at least one order item" do
        order = build(:delivery_order)
        expect(order).not_to be_valid
        expect(order.errors[:order_items]).to include("must have at least one item")
      end

      it "validates maximum 20 order items" do
        order = build(:delivery_order)
        21.times { order.order_items.build(name: "Item", quantity: 1, size: :medium) }
        expect(order).not_to be_valid
        expect(order.errors[:order_items]).to include("cannot exceed 20 items")
      end

      it "allows 1 to 20 order items" do
        order = build(:delivery_order)
        10.times { order.order_items.build(name: "Item", quantity: 1, size: :medium) }
        expect(order).to be_valid
      end
    end
  end

  describe "nested attributes" do
    it "accepts nested attributes for order items" do
      customer = create(:user, :customer)
      order = customer.delivery_orders.create!(
        status: :processing,
        pickup_address: "123 Main St",
        dropoff_address: "456 Oak Ave",
        delivery_type: :immediate,
        order_items_attributes: [
          { name: "Box", quantity: 1, size: :medium },
          { name: "Package", quantity: 2, size: :small }
        ]
      )

      expect(order.order_items.count).to eq(2)
      expect(order.order_items.first.name).to eq("Box")
      expect(order.order_items.last.name).to eq("Package")
    end
  end

  describe "encryption" do
    it "encrypts pickup_address" do
      order = create(:delivery_order, :with_items, pickup_address: "123 Secret St")
      # Access the raw database value
      raw_value = DeliveryOrder.connection.select_value(
        "SELECT pickup_address FROM delivery_orders WHERE id = #{order.id}"
      )
      expect(raw_value).not_to eq("123 Secret St")
    end

    it "encrypts dropoff_address" do
      order = create(:delivery_order, :with_items, dropoff_address: "456 Secret Ave")
      raw_value = DeliveryOrder.connection.select_value(
        "SELECT dropoff_address FROM delivery_orders WHERE id = #{order.id}"
      )
      expect(raw_value).not_to eq("456 Secret Ave")
    end

    it "encrypts description" do
      order = create(:delivery_order, :with_items, description: "Secret delivery notes")
      raw_value = DeliveryOrder.connection.select_value(
        "SELECT description FROM delivery_orders WHERE id = #{order.id}"
      )
      expect(raw_value).not_to eq("Secret delivery notes")
    end
  end

  describe "scopes" do
    let!(:processing_order) { create(:delivery_order, :with_items, status: :processing) }
    let!(:open_order) { create(:delivery_order, :with_items, status: :open) }
    let!(:accepted_order) { create(:delivery_order, :with_items, status: :accepted) }
    let!(:completed_order) { create(:delivery_order, :with_items, status: :completed) }
    let!(:immediate_order) { create(:delivery_order, :with_items, delivery_type: :immediate) }
    let!(:scheduled_order) { create(:delivery_order, :with_items, delivery_type: :scheduled, scheduled_at: 2.hours.from_now) }

    it "returns open orders" do
      expect(DeliveryOrder.open_orders).to contain_exactly(open_order)
    end

    it "returns active deliveries" do
      expect(DeliveryOrder.active_deliveries).to contain_exactly(accepted_order)
    end

    it "returns completed orders" do
      expect(DeliveryOrder.completed).to contain_exactly(completed_order)
    end

    it "returns immediate orders" do
      expect(DeliveryOrder.immediate).to include(processing_order, open_order, immediate_order)
    end
  end

  describe "#assigned?" do
    it "returns true when order has assignment" do
      order = create(:delivery_order, :with_items)
      driver = create(:user, :driver)
      create(:assignment, delivery_order: order, driver: driver)

      expect(order.assigned?).to be true
    end

    it "returns false when order has no assignment" do
      order = create(:delivery_order, :with_items)
      expect(order.assigned?).to be false
    end
  end
end
