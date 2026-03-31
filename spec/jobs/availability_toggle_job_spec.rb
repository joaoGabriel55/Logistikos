# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvailabilityToggleJob, type: :job do
  describe "#perform" do
    let(:driver_profile) { create(:driver_profile, :with_location) }

    context "when driver goes online" do
      before do
        driver_profile.update!(is_available: true)
      end

      it "executes successfully" do
        expect {
          described_class.perform_now(driver_profile.id)
        }.not_to raise_error
      end
    end

    context "when driver goes offline" do
      before do
        driver_profile.update!(is_available: false)
      end

      it "executes successfully" do
        expect {
          described_class.perform_now(driver_profile.id)
        }.not_to raise_error
      end
    end

    context "when profile does not exist" do
      it "handles missing profile gracefully" do
        expect {
          described_class.perform_now(999_999)
        }.not_to raise_error
      end
    end

    describe "idempotency" do
      it "can be safely retried without side effects" do
        driver_profile.update!(is_available: true)

        # Multiple executions should not cause errors
        expect {
          3.times { described_class.perform_now(driver_profile.id) }
        }.not_to raise_error
      end
    end

    describe "queue configuration" do
      it "is queued in the critical queue" do
        expect(described_class.new.queue_name).to eq("critical")
      end
    end
  end
end
