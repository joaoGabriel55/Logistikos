# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do
  describe "GET #new" do
    it "renders the registration page" do
      get :new
      expect(response).to have_http_status(:ok)
    end

    context "when user is already logged in" do
      let(:user) { create(:user, :customer) }
      let(:user_session) { create(:session, user: user) }

      before do
        session[:session_id] = user_session.id
        # Manually set Current.user since we're in a controller test
        allow(Current).to receive(:user).and_return(user)
      end

      it "redirects to customer dashboard" do
        get :new
        expect(response).to redirect_to("/customer/dashboard")
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "New User",
        role: "customer"
      }
    end

    context "with valid params and customer role" do
      it "creates a new user with customer role" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq("newuser@example.com")
        expect(user.name).to eq("New User")
        expect(user.role).to eq("customer")
      end

      it "creates a session and redirects to customer dashboard" do
        post :create, params: valid_params

        expect(response).to redirect_to("/customer/dashboard")
        expect(flash[:notice]).to eq("Account created successfully.")
        expect(session[:user_session_id]).to be_present
      end
    end

    context "with valid params and driver role" do
      let(:driver_params) { valid_params.merge(role: "driver") }

      it "creates a new user with driver role and driver profile with defaults" do
        expect {
          post :create, params: driver_params
        }.to change(User, :count).by(1).and change(DriverProfile, :count).by(1)

        user = User.last
        expect(user.email).to eq("newuser@example.com")
        expect(user.name).to eq("New User")
        expect(user.role).to eq("driver")
        expect(user.driver_profile).to be_present
        expect(user.driver_profile.vehicle_type).to eq("car")
        expect(user.driver_profile.is_available).to be false
        expect(user.driver_profile.radius_preference_km).to eq(10.0)
      end

      it "creates a driver profile with custom vehicle type and radius" do
        custom_params = driver_params.merge(
          vehicle_type: "van",
          radius_preference_km: 25.0
        )

        expect {
          post :create, params: custom_params
        }.to change(User, :count).by(1).and change(DriverProfile, :count).by(1)

        user = User.last
        expect(user.driver_profile.vehicle_type).to eq("van")
        expect(user.driver_profile.radius_preference_km).to eq(25.0)
      end

      it "creates a session and redirects to driver orders page" do
        post :create, params: driver_params

        expect(response).to redirect_to("/driver/orders")
        expect(flash[:notice]).to eq("Account created successfully.")
        expect(session[:user_session_id]).to be_present
      end
    end

    context "with invalid role" do
      it "does not create a user and shows error" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(role: "invalid_role")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["role"]).to eq("Please select a valid role")
      end
    end

    context "without role parameter" do
      it "does not create a user and shows error" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        params_without_role = valid_params.except(:role)

        expect {
          post :create, params: params_without_role
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["role"]).to eq("Please select a valid role")
      end
    end

    context "with invalid params" do
      it "does not create a user with short password" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(password: "short", password_confirmation: "short")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["password"]).to eq("is too short (minimum is 8 characters)")
      end

      it "does not create a user with invalid email format" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(email: "notanemail")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to eq("is invalid")
      end

      it "does not create a user with missing email" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(email: "")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to be_present
      end

      it "does not create a user with missing name" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(name: "")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["name"]).to eq("can't be blank")
      end

      it "does not create a user with missing password" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(password: "", password_confirmation: "")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["password"]).to be_present
      end

      it "does not create a user with mismatched password confirmation" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(password_confirmation: "differentpassword")

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["password_confirmation"]).to eq("doesn't match Password")
      end
    end

    context "with duplicate email" do
      before do
        create(:user, email: "newuser@example.com")
      end

      it "does not create a user and shows error" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"

        expect {
          post :create, params: valid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to eq("has already been taken")
      end
    end
  end
end
