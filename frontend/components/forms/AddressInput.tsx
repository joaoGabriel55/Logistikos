import clsx from 'clsx'
import { RiMapPinLine } from 'react-icons/ri'

interface AddressInputProps {
  id: string
  label: string
  value: string
  onChange: (value: string) => void
  error?: string
  placeholder?: string
  required?: boolean
}

export default function AddressInput({
  id,
  label,
  value,
  onChange,
  error,
  placeholder = 'Enter address',
  required = true
}: AddressInputProps) {
  return (
    <div className="space-y-2">
      <label htmlFor={id} className="block text-label-lg font-medium text-on-surface-variant">
        {label}
        {required && <span className="text-secondary ml-1">*</span>}
      </label>
      <div className="relative">
        <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
          <RiMapPinLine className="h-5 w-5 text-on-surface-variant" />
        </div>
        <input
          id={id}
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className={clsx(
            'input w-full pl-12 text-body-lg',
            error && 'bg-secondary/5 ring-2 ring-secondary/20'
          )}
          placeholder={placeholder}
          required={required}
          autoComplete="street-address"
        />
      </div>
      {error && (
        <p className="text-label-md text-secondary" role="alert">
          {error}
        </p>
      )}
    </div>
  )
}
