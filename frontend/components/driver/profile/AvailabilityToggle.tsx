import { RiCheckLine } from 'react-icons/ri'
import clsx from 'clsx'

interface AvailabilityToggleProps {
  isAvailable: boolean
  onToggle: () => void
}

export default function AvailabilityToggle({ isAvailable, onToggle }: AvailabilityToggleProps) {
  return (
    <div className="sticky top-0 z-10 glass border-b border-outline-variant/10">
      <div className="px-4 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-title-md font-display font-semibold text-white">
              Availability Status
            </h2>
            <p className="text-body-sm text-white/80 mt-1">
              {isAvailable ? 'Receiving order notifications' : 'Not receiving orders'}
            </p>
          </div>
          <button
            type="button"
            onClick={onToggle}
            className={clsx(
              'relative inline-flex h-14 w-28 flex-shrink-0 cursor-pointer rounded-full',
              'transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2',
              'focus:ring-primary/20 touch-target',
              isAvailable ? 'bg-secondary' : 'bg-surface-container-high'
            )}
            role="switch"
            aria-checked={isAvailable}
            aria-label="Toggle availability"
          >
            <span
              className={clsx(
                'pointer-events-none inline-block h-12 w-12 transform rounded-full',
                'bg-white shadow-ambient transition duration-200 ease-in-out',
                'mt-1',
                isAvailable ? 'translate-x-14' : 'translate-x-1'
              )}
            >
              {isAvailable && (
                <RiCheckLine className="h-12 w-12 text-secondary p-2" />
              )}
            </span>
          </button>
        </div>
      </div>
    </div>
  )
}
