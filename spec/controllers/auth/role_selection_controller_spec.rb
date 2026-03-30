# frozen_string_literal: true

require "rails_helper"

RSpec.describe Auth::RoleSelectionController, type: :controller do
  describe "GET #new" do
    context "with pending OAuth user in session" do
      before do
        session[:pending_oauth_user] = {
          provider: "google_oauth2",
          uid: "123456789",
          email: "oauth@example.com",
          name: "OAuth User"
        }
      end

      it "renders the role selection page" do
        get :new

        expect(response).to have_http_status(:ok)
      end
    end

    context "without pending OAuth user" do
      it "redirects to login with error" do
        get :new

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("No pending OAuth registration found.")
      end
    end
  end

  describe "POST #create" do
    context "with pending OAuth user and valid role" do
      before do
        session[:pending_oauth_user] = {
          "provider" => "google_oauth2",
          "uid" => "123456789",
          "email" => "oauth@example.com",
          "name" => "OAuth User"
        }
      end

      it "creates a new user with customer role" do
        expect {
          post :create, params: { role: "customer" }
        }.to change(User, :count).by(1).and change(ConnectedService, :count).by(1)

        user = User.last
        expect(user.email).to eq("oauth@example.com")
        expect(user.name).to eq("OAuth User")
        expect(user.role).to eq("customer")

        connected_service = user.connected_services.first
        expect(connected_service.provider).to eq("google_oauth2")
        expect(connected_service.uid).to eq("123456789")
      end

      it "creates a session and redirects to customer dashboard" do
        post :create, params: { role: "customer" }

        expect(response).to redirect_to("/customer/dashboard")
        expect(flash[:notice]).to eq("Account created successfully.")
        expect(session[:session_id]).to be_present
        expect(session[:pending_oauth_user]).to be_nil
      end

      it "creates a new user with driver role" do
        post :create, params: { role: "driver" }

        user = User.last
        expect(user.role).to eq("driver")
        expect(response).to redirect_to("/driver/orders")
      end
    end

    context "with invalid role" do
      before do
        session[:pending_oauth_user] = {
          "provider" => "google_oauth2",
          "uid" => "123456789",
          "email" => "oauth@example.com",
          "name" => "OAuth User"
        }
      end

      it "does not create a user" do
        expect {
          post :create, params: { role: "invalid_role" }
        }.not_to change(User, :count)

        expect(response).to redirect_to(auth_select_role_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "without pending OAuth user" do
      it "redirects to login" do
        post :create, params: { role: "customer" }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("No pending OAuth registration found.")
      end
    end
  end
end
