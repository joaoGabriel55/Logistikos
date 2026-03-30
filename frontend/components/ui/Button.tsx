import { ButtonHTMLAttributes, ReactNode } from 'react'
import { RiLoader4Line } from 'react-icons/ri'
import clsx from 'clsx'

type ButtonVariant = 'primary' | 'action' | 'tertiary' | 'secondary'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant
  children: ReactNode
  fullWidth?: boolean
  loading?: boolean
}

export default function Button({
  variant = 'primary',
  children,
  fullWidth = false,
  loading = false,
  disabled,
  className = '',
  ...props
}: ButtonProps) {
  const variantClasses = {
    primary: 'btn-primary',
    action: 'btn-action',
    tertiary: 'btn-tertiary',
    secondary: 'bg-surface-container-highest hover:bg-surface-container-high text-on-surface py-3 px-4 rounded-md'
  }

  return (
    <button
      className={clsx(
        'touch-target transition-opacity font-medium',
        variantClasses[variant],
        fullWidth && 'w-full',
        (disabled || loading) && 'opacity-50 cursor-not-allowed',
        className
      )}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <span className="flex items-center justify-center gap-2">
          <RiLoader4Line className="animate-spin h-5 w-5" />
          <span>{children}</span>
        </span>
      ) : (
        children
      )}
    </button>
  )
}
