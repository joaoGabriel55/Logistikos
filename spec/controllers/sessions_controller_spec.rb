# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "renders the login page" do
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
    let(:user) { create(:user, :customer, password: "password123") }

    context "with valid credentials" do
      it "creates a session and redirects to customer dashboard" do
        post :create, params: { email: user.email, password: "password123" }

        expect(response).to redirect_to("/customer/dashboard")
        expect(flash[:notice]).to eq("Signed in successfully.")
        expect(session[:session_id]).to be_present
      end

      it "creates a Session record with IP and user agent" do
        expect {
          post :create, params: { email: user.email, password: "password123" }
        }.to change(Session, :count).by(1)

        session_record = Session.last
        expect(session_record.user).to eq(user)
        expect(session_record.ip_address).to be_present
        expect(session_record.user_agent).to be_present
      end

      context "for a driver" do
        let(:driver) { create(:user, :driver, password: "password123") }

        it "redirects to driver orders feed" do
          post :create, params: { email: driver.email, password: "password123" }

          expect(response).to redirect_to("/driver/orders")
          expect(flash[:notice]).to eq("Signed in successfully.")
        end
      end
    end

    context "with invalid credentials" do
      it "renders login page with error message" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        post :create, params: { email: user.email, password: "wrongpassword" }

        expect(response).to have_http_status(:ok)
        expect(session[:session_id]).to be_nil

        # Parse Inertia response
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to eq("Invalid email or password")
      end

      it "does not create a session record" do
        expect {
          post :create, params: { email: user.email, password: "wrongpassword" }
        }.not_to change(Session, :count)
      end

      it "returns generic error message to prevent user enumeration" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        post :create, params: { email: user.email, password: "wrongpassword" }

        # Check Inertia response structure
        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to eq("Invalid email or password")
      end
    end

    context "with non-existent email" do
      it "returns generic error message to prevent user enumeration" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        post :create, params: { email: "nonexistent@example.com", password: "password123" }

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to eq("Invalid email or password")
      end
    end

    context "with missing email" do
      it "returns validation error for email" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        post :create, params: { email: "", password: "password123" }

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["email"]).to eq("Email can't be blank")
      end
    end

    context "with missing password" do
      it "returns validation error for password" do
        request.headers["X-Inertia"] = "true"
        request.headers["X-Inertia-Version"] = "1"
        post :create, params: { email: user.email, password: "" }

        expect(response).to have_http_status(:ok)
        inertia_data = JSON.parse(response.body)
        expect(inertia_data["props"]["errors"]["password"]).to eq("Password can't be blank")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user, :customer) }
    let(:session_record) { create(:session, user: user) }

    before do
      session[:session_id] = session_record.id
    end

    it "destroys the session and redirects to login" do
      expect {
        delete :destroy
      }.to change(Session, :count).by(-1)

      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Signed out successfully.")
      expect(session[:session_id]).to be_nil
    end

    it "resets Current.user" do
      delete :destroy
      expect(Current.user).to be_nil
    end
  end
end
