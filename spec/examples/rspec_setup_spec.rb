# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RSpec Setup", type: :request do
  describe "basic configuration" do
    it "loads RSpec successfully" do
      expect(true).to be true
    end

    it "has access to Rails environment" do
      expect(Rails.env.test?).to be true
    end

    it "can use shoulda matchers" do
      # This verifies shoulda-matchers is loaded
      expect(Shoulda::Matchers).to be_a(Module)
    end

    it "can use FactoryBot syntax" do
      # This verifies FactoryBot is loaded and configured
      expect(FactoryBot).to be_a(Module)
    end

    it "can generate fake data with Faker" do
      # This verifies Faker is available
      name = Faker::Name.name
      expect(name).to be_a(String)
      expect(name.length).to be > 0
    end
  end

  describe "database connection" do
    it "can connect to the test database" do
      expect(ActiveRecord::Base.connection).to be_active
    end
  end
end
