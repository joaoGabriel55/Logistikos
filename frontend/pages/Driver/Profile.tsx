import { Head } from '@inertiajs/react'
import MobileLayout from '@/components/layout/MobileLayout'
import Button from '@/components/ui/Button'
import { DriverProfile } from '@/types/models'
import { useDriverProfile } from '@/hooks/useDriverProfile'
import {
  AvailabilityToggle,
  VehicleTypeSelector,
  RadiusSlider,
  LocationSection
} from '@/components/driver/profile'

interface DriverProfilePageProps {
  profile: DriverProfile
}

export default function Profile({ profile }: DriverProfilePageProps) {
  const {
    formData,
    processing,
    errors,
    locationState,
    handlers
  } = useDriverProfile({ profile })

  return (
    <>
      <Head title="Driver Profile" />
      <MobileLayout withTopBar withBottomNav className="bg-surface-container-low">
        <div className="min-h-full">
          <AvailabilityToggle
            isAvailable={formData.is_available}
            onToggle={handlers.handleAvailabilityToggle}
          />

          <form onSubmit={handlers.handleSubmit} className="pb-8">
            <VehicleTypeSelector
              selectedVehicleType={formData.vehicle_type}
              onSelect={handlers.handleVehicleSelect}
              error={errors.vehicle_type}
            />

            <RadiusSlider
              value={formData.radius_preference_km}
              onChange={handlers.handleRadiusChange}
              error={errors.radius_preference_km}
            />

            <LocationSection
              latitude={formData.latitude}
              longitude={formData.longitude}
              locationUpdatedAt={profile.locationUpdatedAt}
              locationAccuracy={profile.locationAccuracy}
              gettingLocation={locationState.gettingLocation}
              locationError={locationState.locationError}
              onGetLocation={handlers.handleGetLocation}
              error={errors.latitude}
            />

            {/* Save Button - Bottom Fixed */}
            <div className="fixed bottom-0 left-0 right-0 px-4 py-4 bg-surface-container-low border-t border-outline-variant/10">
              <Button
                type="submit"
                variant="primary"
                fullWidth
                loading={processing}
                disabled={processing}
                className="shadow-ambient"
              >
                Save Profile
              </Button>
            </div>
          </form>
        </div>
      </MobileLayout>
    </>
  )
}
