import clsx from 'clsx'
import { IconType } from 'react-icons'

export interface RoleCardProps {
  title: string
  description: string
  icon: IconType
  actionText: string
  colorScheme: 'primary' | 'secondary'
  onClick: () => void
}

export default function RoleCard({
  title,
  description,
  icon: Icon,
  actionText,
  colorScheme,
  onClick
}: RoleCardProps) {
  const gradientClass = colorScheme === 'primary'
    ? 'from-primary to-primary-container'
    : 'from-secondary to-secondary/80'

  const textColorClass = colorScheme === 'primary'
    ? 'text-primary'
    : 'text-secondary'

  const hoverBorderClass = colorScheme === 'primary'
    ? 'hover:border-primary/20'
    : 'hover:border-secondary/20'

  const hoverOverlayClass = colorScheme === 'primary'
    ? 'from-primary/5'
    : 'from-secondary/5'

  return (
    <button
      type="button"
      onClick={onClick}
      className={clsx(
        'group relative overflow-hidden',
        'bg-surface-container-low hover:bg-surface-container',
        'rounded-2xl p-8 text-left',
        'transition-all duration-300 touch-target',
        'hover:shadow-xl hover:scale-[1.03] active:scale-[0.98]',
        'border-2 border-transparent',
        hoverBorderClass
      )}
    >
      {/* Gradient Overlay on Hover */}
      <div
        className={clsx(
          'absolute inset-0 bg-gradient-to-br to-transparent',
          'opacity-0 group-hover:opacity-100 transition-opacity duration-300',
          hoverOverlayClass
        )}
      />

      <div className="relative">
        {/* Icon */}
        <div
          className={clsx(
            'w-16 h-16 bg-gradient-to-br rounded-2xl',
            'flex items-center justify-center mb-6',
            'group-hover:scale-110 transition-transform duration-300',
            gradientClass
          )}
        >
          <Icon className="w-9 h-9 text-white" />
        </div>

        {/* Title */}
        <h3 className={clsx('text-2xl font-display font-bold mb-2', textColorClass)}>
          {title}
        </h3>

        {/* Description */}
        <p className="text-sm font-body text-on-surface-variant leading-relaxed mb-4">
          {description}
        </p>

        {/* Action Text */}
        <div className={clsx('flex items-center gap-2 font-medium text-sm', textColorClass)}>
          {actionText}
          <span className="group-hover:translate-x-1 transition-transform duration-300">→</span>
        </div>
      </div>
    </button>
  )
}
