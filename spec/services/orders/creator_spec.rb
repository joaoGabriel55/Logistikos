# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orders::Creator, type: :service do
  let(:customer) { create(:user, :customer) }
  let(:driver) { create(:user, :driver) }

  let(:valid_params) do
    {
      pickup_address: "123 Main St, San Francisco, CA",
      dropoff_address: "456 Market St, San Francisco, CA",
      delivery_type: "immediate",
      order_items_attributes: [
        { name: "Box of books", quantity: 1, size: "medium" },
        { name: "Small package", quantity: 2, size: "small" }
      ]
    }
  end

  describe "#call" do
    context "when user has valid payment method" do
      before do
        create(:payment_method, :default, :active, user: customer)
      end

      it "creates a delivery order successfully" do
        result = described_class.new(user: customer, params: valid_params).call

        expect(result).to be_success
        expect(result.order).to be_persisted
        expect(result.order.status).to eq("processing")
      end

      it "creates order with correct attributes" do
        result = described_class.new(user: customer, params: valid_params).call

        order = result.order
        expect(order.pickup_address).to eq("123 Main St, San Francisco, CA")
        expect(order.dropoff_address).to eq("456 Market St, San Francisco, CA")
        expect(order.delivery_type).to eq("immediate")
        expect(order.creator).to eq(customer)
      end

      it "creates associated order items" do
        result = described_class.new(user: customer, params: valid_params).call

        order = result.order
        expect(order.order_items.count).to eq(2)

        first_item = order.order_items.first
        expect(first_item.name).to eq("Box of books")
        expect(first_item.quantity).to eq(1)
        expect(first_item.size).to eq("medium")
      end

      it "generates a tracking code" do
        result = described_class.new(user: customer, params: valid_params).call

        expect(result.order.tracking_code).to match(/^DEL-[A-Z0-9]{6}$/)
      end

      it "handles optional description" do
        params = valid_params.merge(description: "Handle with care")
        result = described_class.new(user: customer, params: params).call

        expect(result.order.description).to eq("Handle with care")
      end

      it "handles optional suggested price" do
        params = valid_params.merge(suggested_price_cents: 1500)
        result = described_class.new(user: customer, params: params).call

        expect(result.order.suggested_price_cents).to eq(1500)
      end

      context "with scheduled delivery" do
        it "creates scheduled order with valid scheduled_at" do
          params = valid_params.merge(
            delivery_type: "scheduled",
            scheduled_at: 2.hours.from_now
          )
          result = described_class.new(user: customer, params: params).call

          expect(result).to be_success
          expect(result.order.delivery_type).to eq("scheduled")
          expect(result.order.scheduled_at).to be_present
        end
      end
    end

    context "when user has no payment method" do
      it "returns failure with error message" do
        result = described_class.new(user: customer, params: valid_params).call

        expect(result).to be_failure
        expect(result.errors).to eq("Payment method required")
      end
    end

    context "when user has expired payment method" do
      before do
        create(:payment_method, :default, :expired, user: customer)
      end

      it "returns failure with error message" do
        result = described_class.new(user: customer, params: valid_params).call

        expect(result).to be_failure
        expect(result.errors).to eq("Payment method required")
      end
    end

    context "when user is not a customer" do
      before do
        create(:payment_method, :default, :active, user: driver)
      end

      it "returns failure with error message" do
        result = described_class.new(user: driver, params: valid_params).call

        expect(result).to be_failure
        expect(result.errors).to eq("User must be a customer")
      end
    end

    context "with invalid params" do
      before do
        create(:payment_method, :default, :active, user: customer)
      end

      it "fails when pickup address is missing" do
        params = valid_params.merge(pickup_address: "")
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:pickup_address]).to be_present
      end

      it "fails when dropoff address is missing" do
        params = valid_params.merge(dropoff_address: "")
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:dropoff_address]).to be_present
      end

      it "fails when pickup address is too short" do
        params = valid_params.merge(pickup_address: "abc")
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:pickup_address]).to be_present
      end

      it "fails when pickup and dropoff addresses are the same" do
        params = valid_params.merge(
          pickup_address: "123 Main St",
          dropoff_address: "123 Main St"
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:dropoff_address]).to be_present
      end

      it "fails when no order items provided" do
        params = valid_params.merge(order_items_attributes: [])
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:order_items]).to be_present
      end

      it "fails when scheduled_at is missing for scheduled delivery" do
        params = valid_params.merge(
          delivery_type: "scheduled",
          scheduled_at: nil
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:scheduled_at]).to be_present
      end

      it "fails when scheduled_at is in the past" do
        params = valid_params.merge(
          delivery_type: "scheduled",
          scheduled_at: 1.hour.ago
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:scheduled_at]).to be_present
      end

      it "fails when suggested price is negative" do
        params = valid_params.merge(suggested_price_cents: -100)
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:suggested_price_cents]).to be_present
      end

      it "fails when description is too long" do
        params = valid_params.merge(description: "a" * 501)
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
        expect(result.errors[:description]).to be_present
      end

      it "fails when item name is missing" do
        params = valid_params.merge(
          order_items_attributes: [
            { name: "", quantity: 1, size: "medium" }
          ]
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
      end

      it "fails when item quantity is zero" do
        params = valid_params.merge(
          order_items_attributes: [
            { name: "Box", quantity: 0, size: "medium" }
          ]
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
      end

      it "fails when item quantity exceeds maximum" do
        params = valid_params.merge(
          order_items_attributes: [
            { name: "Box", quantity: 1000, size: "medium" }
          ]
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
      end

      it "fails when item size is invalid" do
        params = valid_params.merge(
          order_items_attributes: [
            { name: "Box", quantity: 1, size: "extra_large" }
          ]
        )
        result = described_class.new(user: customer, params: params).call

        expect(result).to be_failure
      end
    end

    context "transaction rollback" do
      before do
        create(:payment_method, :default, :active, user: customer)
      end

      it "rolls back order creation if item creation fails" do
        params = valid_params.merge(
          order_items_attributes: [
            { name: "Valid item", quantity: 1, size: "medium" },
            { name: "", quantity: 0, size: "invalid" } # Invalid item
          ]
        )

        expect {
          described_class.new(user: customer, params: params).call
        }.not_to change(DeliveryOrder, :count)
      end
    end
  end

  describe "Result object" do
    it "returns success? true on success" do
      create(:payment_method, :default, :active, user: customer)
      result = described_class.new(user: customer, params: valid_params).call

      expect(result.success?).to be true
      expect(result.failure?).to be false
    end

    it "returns success? false on failure" do
      result = described_class.new(user: customer, params: valid_params).call

      expect(result.success?).to be false
      expect(result.failure?).to be true
    end
  end
end
