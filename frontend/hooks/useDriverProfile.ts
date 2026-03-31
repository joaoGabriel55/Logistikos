import { useForm } from '@inertiajs/react'
import { useState } from 'react'
import { DriverProfile, VehicleType } from '@/types/models'

interface DriverProfileFormData {
  vehicle_type: string
  is_available: boolean
  radius_preference_km: number
  latitude: number | null
  longitude: number | null
}

interface UseDriverProfileOptions {
  profile: DriverProfile
}

interface LocationState {
  gettingLocation: boolean
  locationError: string | null
}

export function useDriverProfile({ profile }: UseDriverProfileOptions) {
  const { data, setData, put, processing, errors } = useForm<DriverProfileFormData>({
    vehicle_type: profile.vehicleType || '',
    is_available: profile.isAvailable,
    radius_preference_km: profile.radiusPreferenceKm,
    latitude: profile.location?.latitude || null,
    longitude: profile.location?.longitude || null
  })

  const [locationState, setLocationState] = useState<LocationState>({
    gettingLocation: false,
    locationError: null
  })

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    put('/driver_profile')
  }

  function handleAvailabilityToggle() {
    setData('is_available', !data.is_available)
    // Auto-submit availability change for immediate feedback
    put('/driver_profile', {
      preserveScroll: true,
      only: ['profile']
    })
  }

  function handleVehicleSelect(vehicleType: VehicleType) {
    setData('vehicle_type', vehicleType)
  }

  function handleRadiusChange(value: number) {
    setData('radius_preference_km', value)
  }

  async function handleGetLocation() {
    if (!navigator.geolocation) {
      setLocationState({
        gettingLocation: false,
        locationError: 'Geolocation is not supported by your browser'
      })
      return
    }

    setLocationState({
      gettingLocation: true,
      locationError: null
    })

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setData({
          ...data,
          latitude: position.coords.latitude,
          longitude: position.coords.longitude
        })
        setLocationState({
          gettingLocation: false,
          locationError: null
        })
      },
      (error) => {
        let errorMessage: string

        switch (error.code) {
          case error.PERMISSION_DENIED:
            errorMessage = 'Location permission denied. Please enable location access in your browser settings.'
            break
          case error.POSITION_UNAVAILABLE:
            errorMessage = 'Location information unavailable. Please try again.'
            break
          case error.TIMEOUT:
            errorMessage = 'Location request timed out. Please try again.'
            break
          default:
            errorMessage = 'An error occurred while getting your location.'
        }

        setLocationState({
          gettingLocation: false,
          locationError: errorMessage
        })
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    )
  }

  return {
    formData: data,
    processing,
    errors,
    locationState,
    handlers: {
      handleSubmit,
      handleAvailabilityToggle,
      handleVehicleSelect,
      handleRadiusChange,
      handleGetLocation
    }
  }
}
