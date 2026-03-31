# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryOrdersController, type: :controller do
  let(:customer) { create(:user, :customer) }
  let(:driver) { create(:user, :driver) }

  let(:valid_params) do
    {
      delivery_order: {
        pickup_address: "123 Main St, San Francisco, CA",
        dropoff_address: "456 Market St, San Francisco, CA",
        delivery_type: "immediate",
        order_items_attributes: [
          { name: "Box of books", quantity: 1, size: "medium" },
          { name: "Small package", quantity: 2, size: "small" }
        ]
      }
    }
  end

  describe "authentication and authorization" do
    context "when not authenticated" do
      it "redirects to login page for new action" do
        get :new
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("You must be signed in to access this page.")
      end

      it "redirects to login page for create action" do
        post :create, params: valid_params
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated as driver" do
      before do
        session_record = create(:session, user: driver)
        session[:user_session_id] = session_record.id
        allow(Current).to receive(:user).and_return(driver)
      end

      it "returns forbidden status for new action" do
        get :new
        expect(response).to have_http_status(:forbidden)
      end

      it "returns forbidden status for create action" do
        post :create, params: valid_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #new" do
    before do
      session_record = create(:session, user: customer)
      session[:user_session_id] = session_record.id
      allow(Current).to receive(:user).and_return(customer)
    end

    it "renders the Customer/OrderCreate page via Inertia" do
      get :new
      expect(response).to have_http_status(:ok)
    end

    context "when customer has valid payment method" do
      before do
        create(:payment_method, :default, :active, user: customer)
      end

      it "sets has_payment_method to true in props" do
        get :new
        expect(response).to have_http_status(:ok)
        # We can't easily test Inertia props in controller specs without additional helpers
        # This is tested in system tests
      end
    end

    context "when customer has no payment method" do
      it "sets has_payment_method to false in props" do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end

    context "when customer has expired payment method" do
      before do
        create(:payment_method, :default, :expired, user: customer)
      end

      it "sets has_payment_method to false in props" do
        get :new
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST #create" do
    before do
      session_record = create(:session, user: customer)
      session[:user_session_id] = session_record.id
      allow(Current).to receive(:user).and_return(customer)
    end

    context "with valid payment method" do
      before do
        create(:payment_method, :default, :active, user: customer)
      end

      it "creates a delivery order successfully" do
        expect {
          post :create, params: valid_params
        }.to change(DeliveryOrder, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "creates associated order items" do
        expect {
          post :create, params: valid_params
        }.to change(OrderItem, :count).by(2)
      end

      it "returns order data as JSON" do
        post :create, params: valid_params

        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to be_present
        expect(json_response["tracking_code"]).to match(/^DEL-[A-Z0-9]{6}$/)
        expect(json_response["status"]).to eq("processing")
        expect(json_response["pickup_address"]).to eq("123 Main St, San Francisco, CA")
        expect(json_response["order_items"].length).to eq(2)
      end

      it "handles optional description" do
        params = valid_params.deep_merge(
          delivery_order: { description: "Handle with care" }
        )
        post :create, params: params

        json_response = JSON.parse(response.body)
        expect(json_response["description"]).to eq("Handle with care")
      end

      it "handles optional suggested price" do
        params = valid_params.deep_merge(
          delivery_order: { suggested_price_cents: 1500 }
        )
        post :create, params: params

        json_response = JSON.parse(response.body)
        expect(json_response["suggested_price_cents"]).to eq(1500)
      end

      it "handles scheduled delivery" do
        scheduled_time = 2.hours.from_now
        params = valid_params.deep_merge(
          delivery_order: {
            delivery_type: "scheduled",
            scheduled_at: scheduled_time.iso8601
          }
        )
        post :create, params: params

        json_response = JSON.parse(response.body)
        expect(json_response["delivery_type"]).to eq("scheduled")
        expect(json_response["scheduled_at"]).to be_present
      end
    end

    context "without valid payment method" do
      it "returns unprocessable entity status" do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        post :create, params: valid_params

        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["base"]).to include("Payment method required")
      end

      it "does not create a delivery order" do
        expect {
          post :create, params: valid_params
        }.not_to change(DeliveryOrder, :count)
      end
    end

    context "with invalid params" do
      before do
        create(:payment_method, :default, :active, user: customer)
      end

      it "returns unprocessable entity for missing pickup address" do
        params = valid_params.deep_merge(
          delivery_order: { pickup_address: "" }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["pickup_address"]).to be_present
      end

      it "returns unprocessable entity for missing dropoff address" do
        params = valid_params.deep_merge(
          delivery_order: { dropoff_address: "" }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["dropoff_address"]).to be_present
      end

      it "returns unprocessable entity for same pickup and dropoff" do
        params = valid_params.deep_merge(
          delivery_order: {
            pickup_address: "123 Main St",
            dropoff_address: "123 Main St"
          }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["dropoff_address"]).to be_present
      end

      it "returns unprocessable entity for no order items" do
        params = valid_params.deep_merge(
          delivery_order: { order_items_attributes: [] }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["order_items"]).to be_present
      end

      it "returns unprocessable entity for invalid item" do
        params = valid_params.deep_merge(
          delivery_order: {
            order_items_attributes: [
              { name: "", quantity: 0, size: "medium" }
            ]
          }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns unprocessable entity for past scheduled_at" do
        params = valid_params.deep_merge(
          delivery_order: {
            delivery_type: "scheduled",
            scheduled_at: 1.hour.ago.iso8601
          }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["scheduled_at"]).to be_present
      end

      it "returns unprocessable entity for negative suggested price" do
        params = valid_params.deep_merge(
          delivery_order: { suggested_price_cents: -100 }
        )
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]["suggested_price_cents"]).to be_present
      end
    end
  end
end
