import clsx from 'clsx'
import { IconType } from 'react-icons'

export interface VehicleOptionConfig {
  value: string
  label: string
  icon: IconType
  description: string
}

interface VehicleOptionProps {
  option: VehicleOptionConfig
  isSelected: boolean
  onSelect: (value: string) => void
}

export default function VehicleOption({ option, isSelected, onSelect }: VehicleOptionProps) {
  const Icon = option.icon

  return (
    <button
      type="button"
      onClick={() => onSelect(option.value)}
      className={clsx(
        'relative overflow-hidden rounded-xl p-4 transition-all duration-200 touch-target',
        'border-2 text-left',
        isSelected
          ? 'border-secondary bg-secondary/5 shadow-md scale-105'
          : 'border-surface-container-high bg-surface-container-lowest hover:border-surface-container hover:bg-surface-container-low'
      )}
    >
      {/* Icon */}
      <Icon
        className={clsx(
          'w-8 h-8 mb-2 transition-colors',
          isSelected ? 'text-secondary' : 'text-on-surface-variant'
        )}
      />

      {/* Label */}
      <div className="text-sm font-medium text-on-surface mb-0.5">
        {option.label}
      </div>

      {/* Description */}
      <div className="text-xs text-on-surface-variant">
        {option.description}
      </div>

      {/* Selected Checkmark */}
      {isSelected && (
        <div className="absolute top-2 right-2 w-5 h-5 bg-secondary rounded-full flex items-center justify-center">
          <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
          </svg>
        </div>
      )}
    </button>
  )
}
