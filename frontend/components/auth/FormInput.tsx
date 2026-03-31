import clsx from 'clsx'
import { IconType } from 'react-icons'
import { ChangeEvent } from 'react'

interface FormInputProps {
  id: string
  label: string
  type: 'text' | 'email' | 'password'
  value: string
  onChange: (e: ChangeEvent<HTMLInputElement>) => void
  icon: IconType
  error?: string
  autoComplete?: string
  autoFocus?: boolean
  required?: boolean
  minLength?: number
  helperText?: string
}

export default function FormInput({
  id,
  label,
  type,
  value,
  onChange,
  icon: Icon,
  error,
  autoComplete,
  autoFocus,
  required,
  minLength,
  helperText
}: FormInputProps) {
  return (
    <div>
      <label htmlFor={id} className="block text-sm font-medium text-on-surface mb-2">
        {label}
      </label>
      <div className="relative">
        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
          <Icon className="h-5 w-5 text-on-surface-variant" />
        </div>
        <input
          id={id}
          type={type}
          value={value}
          onChange={onChange}
          className={clsx(
            'input w-full touch-target pl-12',
            error && 'border-2 border-secondary'
          )}
          required={required}
          autoComplete={autoComplete}
          autoFocus={autoFocus}
          minLength={minLength}
        />
      </div>
      {helperText && !error && (
        <p className="mt-1 text-xs text-on-surface-variant">
          {helperText}
        </p>
      )}
      {error && (
        <p className="mt-2 text-sm text-secondary" role="alert">
          {error}
        </p>
      )}
    </div>
  )
}
