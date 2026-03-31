import {
  RiMotorbikeLine,
  RiCarLine,
  RiTruckLine,
  RiBusLine,
  RiCheckLine
} from 'react-icons/ri'
import clsx from 'clsx'
import { VehicleType } from '@/types/models'

interface VehicleOption {
  type: VehicleType
  label: string
  icon: typeof RiMotorbikeLine
  description: string
}

const vehicleOptions: VehicleOption[] = [
  {
    type: 'motorcycle',
    label: 'Motorcycle',
    icon: RiMotorbikeLine,
    description: 'Small packages, fast delivery'
  },
  {
    type: 'car',
    label: 'Car',
    icon: RiCarLine,
    description: 'Standard deliveries'
  },
  {
    type: 'van',
    label: 'Van',
    icon: RiBusLine,
    description: 'Medium to large loads'
  },
  {
    type: 'truck',
    label: 'Truck',
    icon: RiTruckLine,
    description: 'Heavy and bulk cargo'
  }
]

interface VehicleTypeSelectorProps {
  selectedVehicleType: string
  onSelect: (vehicleType: VehicleType) => void
  error?: string
}

export default function VehicleTypeSelector({
  selectedVehicleType,
  onSelect,
  error
}: VehicleTypeSelectorProps) {
  return (
    <section className="px-4 py-6">
      <h3 className="text-headline-sm font-display font-semibold text-primary mb-2">
        Vehicle Type
      </h3>
      <p className="text-body-md text-on-surface-variant mb-5">
        Select your vehicle to receive compatible delivery orders
      </p>

      <div className="grid grid-cols-2 gap-4">
        {vehicleOptions.map((option) => {
          const Icon = option.icon
          const isSelected = selectedVehicleType === option.type

          return (
            <button
              key={option.type}
              type="button"
              onClick={() => onSelect(option.type)}
              className={clsx(
                'relative bg-surface-container-lowest rounded-md p-4',
                'transition-all duration-200 touch-target',
                'focus:outline-none focus:ring-2 focus:ring-primary/20',
                isSelected
                  ? 'ring-2 ring-primary shadow-ambient'
                  : 'hover:bg-surface-container-highest'
              )}
            >
              {/* Selected indicator */}
              {isSelected && (
                <div className="absolute top-2 right-2 bg-primary rounded-full p-1">
                  <RiCheckLine className="h-4 w-4 text-white" />
                </div>
              )}

              <div className="flex flex-col items-center text-center">
                <div
                  className={clsx(
                    'w-16 h-16 rounded-full flex items-center justify-center mb-3',
                    isSelected
                      ? 'bg-primary text-white'
                      : 'bg-surface-container-high text-on-surface-variant'
                  )}
                >
                  <Icon className="h-8 w-8" />
                </div>
                <span
                  className={clsx(
                    'text-title-sm font-medium block mb-1',
                    isSelected ? 'text-primary' : 'text-on-surface'
                  )}
                >
                  {option.label}
                </span>
                <span className="text-label-md text-on-surface-variant">
                  {option.description}
                </span>
              </div>
            </button>
          )
        })}
      </div>

      {error && (
        <p className="mt-3 text-sm text-secondary" role="alert">
          {error}
        </p>
      )}
    </section>
  )
}
