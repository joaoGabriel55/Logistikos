import { ReactNode } from 'react'
import clsx from 'clsx'

interface EmptyStateProps {
  title: string
  description?: string
  icon?: ReactNode
  action?: ReactNode
  className?: string
}

export default function EmptyState({
  title,
  description,
  icon,
  action,
  className = ''
}: EmptyStateProps) {
  return (
    <div className={clsx('flex flex-col items-center justify-center text-center p-8', className)}>
      {icon && (
        <div className="mb-4 text-on-surface-variant opacity-50">
          {icon}
        </div>
      )}
      <h3 className="text-lg font-display font-semibold text-on-surface mb-2">
        {title}
      </h3>
      {description && (
        <p className="text-sm text-on-surface-variant mb-6 max-w-md">
          {description}
        </p>
      )}
      {action && <div>{action}</div>}
    </div>
  )
}
