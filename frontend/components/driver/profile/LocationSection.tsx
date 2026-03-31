import { RiMapPinLine, RiLoader4Line } from 'react-icons/ri'
import Button from '@/components/ui/Button'

interface LocationSectionProps {
  latitude: number | null
  longitude: number | null
  locationUpdatedAt?: string
  locationAccuracy?: number
  gettingLocation: boolean
  locationError: string | null
  onGetLocation: () => void
  error?: string
}

export default function LocationSection({
  latitude,
  longitude,
  locationUpdatedAt,
  locationAccuracy,
  gettingLocation,
  locationError,
  onGetLocation,
  error
}: LocationSectionProps) {
  const hasLocation = latitude !== null && longitude !== null

  return (
    <section className="px-4 py-6">
      <h3 className="text-headline-sm font-display font-semibold text-primary mb-2">
        Current Location
      </h3>
      <p className="text-body-md text-on-surface-variant mb-5">
        Update your location for accurate distance calculations
      </p>

      <div className="bg-surface-container-lowest rounded-md p-4">
        {hasLocation ? (
          <div className="flex items-start gap-3 mb-4">
            <div className="bg-primary/10 rounded-full p-2 flex-shrink-0">
              <RiMapPinLine className="h-5 w-5 text-primary" />
            </div>
            <div className="flex-1">
              <p className="text-title-sm font-medium text-on-surface mb-1">
                Location Set
              </p>
              <p className="text-body-sm text-on-surface-variant font-mono">
                {latitude!.toFixed(6)}, {longitude!.toFixed(6)}
              </p>
              {locationUpdatedAt && (
                <p className="text-label-md text-on-surface-variant mt-1">
                  Last updated: {new Date(locationUpdatedAt).toLocaleString()}
                </p>
              )}
              {locationAccuracy && (
                <p className="text-label-md text-on-surface-variant">
                  Accuracy: ±{Math.round(locationAccuracy)}m
                </p>
              )}
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-3 mb-4 p-4 bg-surface-container-high rounded-md">
            <RiMapPinLine className="h-6 w-6 text-on-surface-variant flex-shrink-0" />
            <p className="text-body-md text-on-surface-variant">
              No location set. Click below to use your current location.
            </p>
          </div>
        )}

        {locationError && (
          <div className="mb-4 p-3 bg-secondary/10 rounded-md">
            <p className="text-body-sm text-secondary">{locationError}</p>
          </div>
        )}

        <Button
          type="button"
          variant="secondary"
          fullWidth
          onClick={onGetLocation}
          disabled={gettingLocation}
          className="touch-target"
        >
          {gettingLocation ? (
            <span className="flex items-center justify-center gap-2">
              <RiLoader4Line className="animate-spin h-5 w-5" />
              Getting Location...
            </span>
          ) : (
            <span className="flex items-center justify-center gap-2">
              <RiMapPinLine className="h-5 w-5" />
              {hasLocation ? 'Update' : 'Get'} Current Location
            </span>
          )}
        </Button>
      </div>

      {error && (
        <p className="mt-3 text-sm text-secondary" role="alert">
          {error}
        </p>
      )}
    </section>
  )
}
