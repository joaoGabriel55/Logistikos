import { Head, useForm } from '@inertiajs/react'
import { FormEvent } from 'react'
import { RiUserLine, RiTruckLine } from 'react-icons/ri'
import clsx from 'clsx'

interface SelectRoleProps {
  user: {
    email: string
    name: string
  }
}

export default function SelectRole({ user }: SelectRoleProps) {
  const { data, setData, post, processing, errors } = useForm({
    role: ''
  })

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    post('/auth/select_role')
  }

  return (
    <>
      <Head title="Select Your Role" />
      <div className="min-h-screen bg-surface flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          {/* Main Card */}
          <div className="bg-surface-container-lowest rounded-md shadow-ambient p-6 sm:p-8">
            {/* Header */}
            <div className="mb-8">
              <h1 className="text-4xl font-display font-bold text-primary mb-2">
                Welcome, {user.name}!
              </h1>
              <p className="text-sm font-body text-on-surface-variant">
                How would you like to use Logistikos?
              </p>
            </div>

            {/* Role Selection Form */}
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Role Options */}
              <div className="space-y-3">
                {/* Customer Option */}
                <button
                  type="button"
                  onClick={() => setData('role', 'customer')}
                  className={clsx(
                    'w-full p-6 rounded-md transition-all touch-target',
                    'flex items-start gap-4 text-left',
                    data.role === 'customer'
                      ? 'bg-gradient-to-r from-primary to-primary-container text-white ring-2 ring-primary'
                      : 'bg-surface-container-highest hover:bg-surface-container-high text-on-surface'
                  )}
                >
                  <div className={clsx(
                    'p-3 rounded-md',
                    data.role === 'customer'
                      ? 'bg-white/20'
                      : 'bg-surface-container'
                  )}>
                    <RiUserLine className="w-6 h-6" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-lg mb-1">
                      I need deliveries
                    </h3>
                    <p className={clsx(
                      'text-sm',
                      data.role === 'customer'
                        ? 'text-white/90'
                        : 'text-on-surface-variant'
                    )}>
                      Send packages and items to any location. Track your deliveries in real-time.
                    </p>
                  </div>
                  {data.role === 'customer' && (
                    <div className="shrink-0">
                      <div className="w-6 h-6 rounded-full bg-white flex items-center justify-center">
                        <div className="w-3 h-3 rounded-full bg-primary" />
                      </div>
                    </div>
                  )}
                </button>

                {/* Driver Option */}
                <button
                  type="button"
                  onClick={() => setData('role', 'driver')}
                  className={clsx(
                    'w-full p-6 rounded-md transition-all touch-target',
                    'flex items-start gap-4 text-left',
                    data.role === 'driver'
                      ? 'bg-gradient-to-r from-primary to-primary-container text-white ring-2 ring-primary'
                      : 'bg-surface-container-highest hover:bg-surface-container-high text-on-surface'
                  )}
                >
                  <div className={clsx(
                    'p-3 rounded-md',
                    data.role === 'driver'
                      ? 'bg-white/20'
                      : 'bg-surface-container'
                  )}>
                    <RiTruckLine className="w-6 h-6" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-lg mb-1">
                      I want to deliver
                    </h3>
                    <p className={clsx(
                      'text-sm',
                      data.role === 'driver'
                        ? 'text-white/90'
                        : 'text-on-surface-variant'
                    )}>
                      Earn money delivering packages on your schedule. Be your own boss.
                    </p>
                  </div>
                  {data.role === 'driver' && (
                    <div className="shrink-0">
                      <div className="w-6 h-6 rounded-full bg-white flex items-center justify-center">
                        <div className="w-3 h-3 rounded-full bg-primary" />
                      </div>
                    </div>
                  )}
                </button>
              </div>

              {/* Error Message */}
              {errors.role && (
                <p className="text-sm text-secondary" role="alert">
                  {errors.role}
                </p>
              )}

              {/* Submit Button */}
              <button
                type="submit"
                disabled={processing || !data.role}
                className={clsx(
                  'w-full btn-primary touch-target',
                  'disabled:opacity-50 disabled:cursor-not-allowed'
                )}
              >
                {processing ? 'Creating account...' : 'Continue'}
              </button>
            </form>
          </div>

          {/* Email Display */}
          <div className="mt-6 bg-surface-container-low rounded-md p-4 text-center">
            <p className="text-xs text-on-surface-variant">
              Signing up with <span className="font-medium">{user.email}</span>
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
