# frozen_string_literal: true

class DriverProfilesController < ApplicationController
  before_action :authenticate
  before_action :require_driver
  before_action :set_driver_profile, only: [ :show, :edit, :update ]

  def show
    render inertia: "Driver/Profile", props: {
      profile: DriverProfileSerializer.new(@driver_profile).as_json
    }
  end

  def edit
    render inertia: "Driver/ProfileEdit", props: {
      profile: DriverProfileSerializer.new(@driver_profile).as_json,
      vehicle_types: DriverProfile.vehicle_types.keys
    }
  end

  def update
    if @driver_profile.update(driver_profile_params)
      # Enqueue availability toggle worker if availability changed
      if saved_change_to_is_available?
        AvailabilityToggleJob.perform_later(@driver_profile.id)
      end

      redirect_to driver_profile_path, notice: "Profile updated successfully."
    else
      render inertia: "Driver/ProfileEdit", props: {
        profile: DriverProfileSerializer.new(@driver_profile).as_json,
        vehicle_types: DriverProfile.vehicle_types.keys,
        errors: @driver_profile.errors.messages
      }, status: :unprocessable_entity
    end
  end

  def update_location
    lat = params[:latitude]
    lng = params[:longitude]

    if lat.blank? || lng.blank?
      return render json: { error: "Latitude and longitude are required" }, status: :bad_request
    end

    begin
      @driver_profile = Current.user.driver_profile
      @driver_profile.set_location(lat, lng)

      if @driver_profile.save
        render json: {
          success: true,
          location: DriverProfileSerializer.new(@driver_profile).as_json[:location]
        }
      else
        render json: { error: @driver_profile.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    end
  end

  private

  def set_driver_profile
    @driver_profile = Current.user.driver_profile

    unless @driver_profile
      redirect_to root_path, alert: "Please complete your driver profile setup."
    end
  end

  def driver_profile_params
    params.require(:driver_profile).permit(
      :vehicle_type,
      :is_available,
      :radius_preference_km
    )
  end

  def saved_change_to_is_available?
    @driver_profile.saved_change_to_is_available?
  end
end
