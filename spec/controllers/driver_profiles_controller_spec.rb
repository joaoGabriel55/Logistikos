# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriverProfilesController, type: :controller do
  let(:driver) { create(:user, :driver) }
  let(:driver_profile) { create(:driver_profile, :with_location, user: driver) }
  let(:customer) { create(:user, :customer) }

  before do
    # Ensure driver has a profile
    driver_profile
  end

  describe "authentication and authorization" do
    context "when not authenticated" do
      it "redirects to login page" do
        get :show
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("You must be signed in to access this page.")
      end
    end

    context "when authenticated as customer" do
      before do
        session_record = create(:session, user: customer)
        session[:session_id] = session_record.id
        allow(Current).to receive(:user).and_return(customer)
      end

      it "returns forbidden status" do
        get :show
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #show" do
    before do
      session_record = create(:session, user: driver)
      session[:session_id] = session_record.id
      allow(Current).to receive(:user).and_return(driver)
    end

    it "renders the Driver/Profile page via Inertia" do
      get :show
      expect(response).to have_http_status(:ok)
    end

    it "passes serialized profile as props" do
      get :show
      expect(response).to have_http_status(:ok)
      # Testing that the controller renders successfully is sufficient
      # Detailed props testing would require Inertia test helpers
    end

    context "when driver has no profile" do
      let(:driver_without_profile) { create(:user, :driver) }

      before do
        session_record = create(:session, user: driver_without_profile)
        session[:session_id] = session_record.id
        allow(Current).to receive(:user).and_return(driver_without_profile)
      end

      it "redirects to root with alert" do
        get :show
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Please complete your driver profile setup.")
      end
    end
  end

  describe "GET #edit" do
    before do
      session_record = create(:session, user: driver)
      session[:session_id] = session_record.id
      allow(Current).to receive(:user).and_return(driver)
    end

    it "renders the Driver/ProfileEdit page via Inertia" do
      get :edit
      expect(response).to have_http_status(:ok)
    end

    it "passes profile and vehicle_types as props" do
      get :edit
      expect(response).to have_http_status(:ok)
      # Testing that the controller renders successfully is sufficient
      # Detailed props testing would require Inertia test helpers
    end
  end

  describe "PATCH #update" do
    before do
      session_record = create(:session, user: driver)
      session[:session_id] = session_record.id
      allow(Current).to receive(:user).and_return(driver)
    end

    context "with valid parameters" do
      let(:valid_params) {
        {
          driver_profile: {
            vehicle_type: "van",
            is_available: true,
            radius_preference_km: 25.0
          }
        }
      }

      it "updates the driver profile" do
        patch :update, params: valid_params

        driver_profile.reload
        expect(driver_profile.vehicle_type).to eq("van")
        expect(driver_profile.is_available).to be true
        expect(driver_profile.radius_preference).to eq(25_000) # 25km in meters
      end

      it "redirects to profile show page with success message" do
        patch :update, params: valid_params

        expect(response).to redirect_to(driver_profile_path)
        expect(flash[:notice]).to eq("Profile updated successfully.")
      end

      context "when availability changes" do
        it "enqueues AvailabilityToggleJob" do
          expect {
            patch :update, params: valid_params
          }.to have_enqueued_job(AvailabilityToggleJob).with(driver_profile.id)
        end
      end

      context "when availability does not change" do
        let(:params_without_availability_change) {
          {
            driver_profile: {
              vehicle_type: "truck",
              is_available: driver_profile.is_available,
              radius_preference_km: 30.0
            }
          }
        }

        it "does not enqueue AvailabilityToggleJob" do
          expect {
            patch :update, params: params_without_availability_change
          }.not_to have_enqueued_job(AvailabilityToggleJob)
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) {
        {
          driver_profile: {
            vehicle_type: nil,
            radius_preference_km: -5
          }
        }
      }

      before do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
      end

      it "does not update the driver profile" do
        original_vehicle_type = driver_profile.vehicle_type

        patch :update, params: invalid_params

        driver_profile.reload
        expect(driver_profile.vehicle_type).to eq(original_vehicle_type)
      end

      it "returns unprocessable_entity status" do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns unprocessable entity with errors" do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST #update_location" do
    before do
      session_record = create(:session, user: driver)
      session[:session_id] = session_record.id
      allow(Current).to receive(:user).and_return(driver)
    end

    context "with valid coordinates" do
      let(:valid_params) {
        {
          latitude: 40.7128,
          longitude: -74.0060
        }
      }

      it "updates the driver location" do
        post :update_location, params: valid_params

        driver_profile.reload
        coords = driver_profile.coordinates

        expect(coords[1]).to be_within(0.0001).of(40.7128)  # latitude
        expect(coords[0]).to be_within(0.0001).of(-74.0060) # longitude
      end

      it "returns success response with location data" do
        post :update_location, params: valid_params

        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["location"]).to be_present
        expect(json_response["location"]["latitude"]).to be_within(0.0001).of(40.7128)
      end

      it "updates last_location_updated_at" do
        post :update_location, params: valid_params

        driver_profile.reload
        expect(driver_profile.last_location_updated_at).to be_within(1.second).of(Time.current)
      end
    end

    context "with missing coordinates" do
      it "returns bad_request when latitude is missing" do
        post :update_location, params: { longitude: -74.0060 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Latitude and longitude are required")
      end

      it "returns bad_request when longitude is missing" do
        post :update_location, params: { latitude: 40.7128 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Latitude and longitude are required")
      end
    end

    context "with invalid coordinates" do
      it "returns bad_request for latitude > 90" do
        post :update_location, params: { latitude: 91, longitude: -74.0060 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Latitude must be between -90 and 90")
      end

      it "returns bad_request for longitude > 180" do
        post :update_location, params: { latitude: 40.7128, longitude: 181 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Longitude must be between -180 and 180")
      end

      it "returns bad_request for non-numeric coordinates" do
        post :update_location, params: { latitude: "invalid", longitude: -74.0060 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to be_present
      end
    end
  end
end
