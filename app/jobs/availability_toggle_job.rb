# frozen_string_literal: true

# AvailabilityToggleJob
#
# Background task that processes driver availability changes asynchronously.
# - When going offline (is_available: false): Removes driver from active feed caches
# - When coming online (is_available: true): Rebuilds feed with driver's preferences
#
# Idempotency: Safe to retry as it checks current state before acting.
# Retries: Max 3 with exponential backoff (Rails default)
#
# Queue: critical (low latency required for driver experience)
class AvailabilityToggleJob < ApplicationJob
  queue_as :critical

  # Retry configuration with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(driver_profile_id)
    driver_profile = DriverProfile.find_by(id: driver_profile_id)

    # Idempotency guard: If profile no longer exists, job is no-op
    return unless driver_profile

    if driver_profile.is_available?
      handle_driver_online(driver_profile)
    else
      handle_driver_offline(driver_profile)
    end
  end

  private

  def handle_driver_online(driver_profile)
    # TODO (Ticket 013 - Order Feed): Rehydrate driver's order feed cache
    # This will rebuild the feed with orders matching the driver's:
    # - vehicle_type compatibility
    # - radius_preference (using ST_DWithin)
    # - current location

    Rails.logger.info(
      "Driver #{driver_profile.user_id} went online " \
      "(vehicle: #{driver_profile.vehicle_type}, radius: #{driver_profile.radius_preference_km}km)"
    )
  end

  def handle_driver_offline(driver_profile)
    # TODO (Ticket 013 - Order Feed): Clear driver's feed cache
    # Remove all cached feed entries for this driver since they won't
    # receive notifications while offline

    Rails.logger.info("Driver #{driver_profile.user_id} went offline")
  end
end
