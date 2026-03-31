import clsx from 'clsx'

export interface RadiusOptionConfig {
  value: string
  label: string
  description: string
}

interface RadiusOptionProps {
  option: RadiusOptionConfig
  isSelected: boolean
  onSelect: (value: string) => void
}

export default function RadiusOption({ option, isSelected, onSelect }: RadiusOptionProps) {
  return (
    <button
      type="button"
      onClick={() => onSelect(option.value)}
      className={clsx(
        'rounded-xl p-4 transition-all duration-200 touch-target text-center',
        'border-2',
        isSelected
          ? 'border-secondary bg-secondary/5 shadow-md scale-105'
          : 'border-surface-container-high bg-surface-container-lowest hover:border-surface-container hover:bg-surface-container-low'
      )}
    >
      {/* Label (e.g., "5 km") */}
      <div
        className={clsx(
          'text-2xl font-display font-bold mb-1 transition-colors',
          isSelected ? 'text-secondary' : 'text-on-surface'
        )}
      >
        {option.label}
      </div>

      {/* Description (e.g., "City center") */}
      <div className="text-xs text-on-surface-variant">
        {option.description}
      </div>
    </button>
  )
}
