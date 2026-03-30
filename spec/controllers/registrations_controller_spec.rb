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

    context "with valid params" do
      it "creates a new user" do
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
        expect(session[:session_id]).to be_present
      end

      context "for a driver" do
        let(:driver_params) do
          valid_params.merge(role: "driver")
        end

        it "redirects to driver orders feed" do
          post :create, params: driver_params

          expect(response).to redirect_to("/driver/orders")
          expect(User.last.role).to eq("driver")
        end
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

      it "does not create a user with missing role" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        invalid_params = valid_params.merge(role: nil)

        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["role"]).to eq("can't be blank")
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
