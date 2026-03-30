# frozen_string_literal: true

require "rails_helper"

RSpec.describe Auth::OmniauthCallbacksController, type: :controller do
  describe "GET #google_oauth2" do
    before do
      OmniAuth.config.test_mode = true
    end

    after do
      OmniAuth.config.test_mode = false
    end

    context "when user already exists with connected service" do
      let(:auth_hash) do
        OmniAuth::AuthHash.new({
          provider: "google_oauth2",
          uid: "existing-user-123",
          info: {
            email: "existing@example.com",
            name: "Existing OAuth User"
          }
        })
      end

      let!(:existing_user) do
        user = create(:user, :customer, email: "existing@example.com")
        create(:connected_service, user: user, provider: "google_oauth2", uid: "existing-user-123")
        user
      end

      before do
        request.env["omniauth.auth"] = auth_hash
      end

      it "logs in the existing user" do
        get :google_oauth2, params: { provider: "google_oauth2" }

        expect(response).to redirect_to("/customer/dashboard")
        expect(flash[:notice]).to eq("Signed in successfully with Google.")
        expect(session[:session_id]).to be_present
      end

      it "creates a new session record" do
        expect {
          get :google_oauth2, params: { provider: "google_oauth2" }
        }.to change(Session, :count).by(1)
      end

      it "does not create a new connected service" do
        expect {
          get :google_oauth2, params: { provider: "google_oauth2" }
        }.not_to change(ConnectedService, :count)
      end
    end

    context "when user exists with matching email but no connected service" do
      let(:auth_hash) do
        OmniAuth::AuthHash.new({
          provider: "google_oauth2",
          uid: "new-oauth-123",
          info: {
            email: "existing@example.com",
            name: "Existing User"
          }
        })
      end

      let!(:existing_user) do
        create(:user, :customer, email: "existing@example.com")
      end

      before do
        request.env["omniauth.auth"] = auth_hash
      end

      it "links the OAuth account to existing user" do
        expect {
          get :google_oauth2, params: { provider: "google_oauth2" }
        }.to change(ConnectedService, :count).by(1)

        connected_service = ConnectedService.last
        expect(connected_service.user).to eq(existing_user)
        expect(connected_service.provider).to eq("google_oauth2")
        expect(connected_service.uid).to eq("new-oauth-123")
      end

      it "logs in the user" do
        get :google_oauth2, params: { provider: "google_oauth2" }

        expect(response).to redirect_to("/customer/dashboard")
        expect(flash[:notice]).to eq("Signed in successfully with Google.")
      end
    end

    context "when user does not exist" do
      # Use a unique email to ensure no user exists
      let(:new_auth_hash) do
        OmniAuth::AuthHash.new({
          provider: "google_oauth2",
          uid: "new-user-#{SecureRandom.hex(8)}",
          info: {
            email: "newuser-#{SecureRandom.hex(8)}@example.com",
            name: "New OAuth User"
          }
        })
      end

      before do
        request.env["omniauth.auth"] = new_auth_hash
      end

      it "redirects to role selection" do
        get :google_oauth2, params: { provider: "google_oauth2" }

        expect(response).to redirect_to(auth_select_role_path)
        expect(session[:pending_oauth_user]).to be_present
        pending_user = session[:pending_oauth_user]
        expect(pending_user["provider"]).to eq("google_oauth2")
        expect(pending_user["uid"]).to be_present
        expect(pending_user["email"]).to be_present
        expect(pending_user["name"]).to be_present
      end

      it "does not create a user yet" do
        expect {
          get :google_oauth2, params: { provider: "google_oauth2" }
        }.not_to change(User, :count)
      end
    end

    context "when auth fails" do
      before do
        request.env["omniauth.auth"] = nil
      end

      it "redirects to login with error" do
        get :google_oauth2, params: { provider: "google_oauth2" }

        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq("Authentication failed. Please try again.")
      end
    end
  end

  describe "GET #failure" do
    it "redirects to login with error message" do
      get :failure, params: { message: "invalid_credentials" }

      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Authentication failed: invalid_credentials")
    end
  end
end
