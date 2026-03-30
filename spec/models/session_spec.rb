# frozen_string_literal: true

require "rails_helper"

RSpec.describe Session, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    let(:user) { create(:user, :customer) }
    let!(:old_session) { create(:session, user: user, created_at: 31.days.ago) }
    let!(:recent_session) { create(:session, user: user, created_at: 1.day.ago) }

    it "returns sessions in descending order by created_at" do
      expect(Session.recent).to eq([ recent_session, old_session ])
    end

    it "returns sessions for a specific user" do
      other_user = create(:user, :driver)
      other_session = create(:session, user: other_user)

      expect(Session.for_user(user.id)).to match_array([ old_session, recent_session ])
      expect(Session.for_user(user.id)).not_to include(other_session)
    end
  end

  describe ".cleanup_old_sessions" do
    let(:user) { create(:user, :customer) }

    before do
      create(:session, user: user, created_at: 31.days.ago)
      create(:session, user: user, created_at: 29.days.ago)
      create(:session, user: user, created_at: 1.day.ago)
    end

    it "deletes sessions older than 30 days" do
      expect {
        Session.cleanup_old_sessions(30)
      }.to change(Session, :count).by(-1)

      expect(Session.where("created_at < ?", 30.days.ago)).to be_empty
    end

    it "keeps sessions newer than 30 days" do
      Session.cleanup_old_sessions(30)

      expect(Session.where("created_at >= ?", 30.days.ago).count).to eq(2)
    end
  end

  describe "IP address hashing" do
    it "hashes the IP address before saving" do
      session = create(:session, ip_address: "192.168.1.1")

      # IP should be hashed (truncated SHA256)
      expect(session.ip_address).not_to eq("192.168.1.1")
      expect(session.ip_address.length).to eq(16)
    end

    it "produces consistent hashes for the same IP" do
      session1 = build(:session, ip_address: "192.168.1.1")
      session1.save!

      session2 = build(:session, ip_address: "192.168.1.1")
      session2.save!

      expect(session1.ip_address).to eq(session2.ip_address)
    end

    it "does not hash if IP is nil" do
      session = create(:session, ip_address: nil)
      expect(session.ip_address).to be_nil
    end
  end

  describe "user agent truncation" do
    it "truncates user agent to 255 characters" do
      long_ua = "a" * 300
      session = create(:session, user_agent: long_ua)

      expect(session.user_agent.length).to eq(255)
    end

    it "does not modify user agent under 255 characters" do
      short_ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
      session = create(:session, user_agent: short_ua)

      expect(session.user_agent).to eq(short_ua)
    end

    it "does not truncate if user agent is nil" do
      session = create(:session, user_agent: nil)
      expect(session.user_agent).to be_nil
    end
  end

  describe "PII filtering" do
    it "filters sensitive attributes from logs" do
      expect(Session.filter_attributes).to include(:ip_address, :user_agent)
    end
  end
end
