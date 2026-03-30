import { Head, Link, useForm } from '@inertiajs/react'
import { FormEvent } from 'react'
import { RiGoogleFill, RiMailLine, RiLockLine, RiUserLine } from 'react-icons/ri'
import clsx from 'clsx'
import type { UserRole } from '../../types/models'
import { useOAuthRedirect } from '@/hooks/useOAuthRedirect'

interface RegisterProps {
  googleOAuthUrl?: string
}

export default function Register({ googleOAuthUrl }: RegisterProps) {
  const { data, setData, post, processing, errors } = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
    role: '' as UserRole | ''
  })

  // OAuth redirect handler using custom hook
  const handleGoogleRegister = useOAuthRedirect(googleOAuthUrl || '/auth/google_oauth2')

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    post('/register')
  }

  return (
    <>
      <Head title="Create Account" />
      <div className="min-h-screen bg-surface flex items-center justify-center p-4 py-8">
        <div className="w-full max-w-md">
          {/* Main Card */}
          <div className="bg-surface-container-lowest rounded-md shadow-ambient p-6 sm:p-8">
            {/* Header */}
            <div className="mb-8">
              <h1 className="text-4xl font-display font-bold text-primary mb-2">
                Create Account
              </h1>
              <p className="text-sm font-body text-on-surface-variant">
                Join the Logistikos marketplace
              </p>
            </div>

            {/* Google OAuth Button */}
            {googleOAuthUrl && (
              <div className="mb-6">
                <button
                  type="button"
                  onClick={handleGoogleRegister}
                  className={clsx(
                    'w-full flex items-center justify-center gap-3',
                    'bg-surface-container-highest hover:bg-surface-container-high',
                    'transition-colors py-3.5 px-4 rounded-md',
                    'font-medium text-on-surface touch-target'
                  )}
                >
                  <RiGoogleFill className="w-5 h-5" />
                  Continue with Google
                </button>
              </div>
            )}

            {/* Divider */}
            {googleOAuthUrl && (
              <div className="relative mb-6">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-surface-container-high"></div>
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-4 bg-surface-container-lowest text-on-surface-variant">
                    Or create account with email
                  </span>
                </div>
              </div>
            )}

            {/* Registration Form */}
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Role Selection */}
              <div>
                <label className="block text-sm font-medium text-on-surface mb-3">
                  I want to
                </label>
                <div className="grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => setData('role', 'customer')}
                    className={clsx(
                      'py-3.5 px-4 rounded-md font-medium transition-all touch-target',
                      data.role === 'customer'
                        ? 'bg-gradient-to-r from-primary to-primary-container text-white'
                        : 'bg-surface-container-highest text-on-surface hover:bg-surface-container-high'
                    )}
                  >
                    Send Items
                  </button>
                  <button
                    type="button"
                    onClick={() => setData('role', 'driver')}
                    className={clsx(
                      'py-3.5 px-4 rounded-md font-medium transition-all touch-target',
                      data.role === 'driver'
                        ? 'bg-gradient-to-r from-primary to-primary-container text-white'
                        : 'bg-surface-container-highest text-on-surface hover:bg-surface-container-high'
                    )}
                  >
                    Deliver Items
                  </button>
                </div>
                {errors.role && (
                  <p className="mt-2 text-sm text-secondary" role="alert">
                    {errors.role}
                  </p>
                )}
              </div>

              {/* Name Field */}
              <div>
                <label
                  htmlFor="name"
                  className="block text-sm font-medium text-on-surface mb-2"
                >
                  Full name
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <RiUserLine className="h-5 w-5 text-on-surface-variant" />
                  </div>
                  <input
                    id="name"
                    type="text"
                    value={data.name}
                    onChange={e => setData('name', e.target.value)}
                    className="input w-full touch-target pl-10"
                    required
                    autoComplete="name"
                    autoFocus
                  />
                </div>
                {errors.name && (
                  <p className="mt-2 text-sm text-secondary" role="alert">
                    {errors.name}
                  </p>
                )}
              </div>

              {/* Email Field */}
              <div>
                <label
                  htmlFor="email"
                  className="block text-sm font-medium text-on-surface mb-2"
                >
                  Email address
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <RiMailLine className="h-5 w-5 text-on-surface-variant" />
                  </div>
                  <input
                    id="email"
                    type="email"
                    value={data.email}
                    onChange={e => setData('email', e.target.value)}
                    className="input w-full touch-target pl-10"
                    required
                    autoComplete="email"
                  />
                </div>
                {errors.email && (
                  <p className="mt-2 text-sm text-secondary" role="alert">
                    {errors.email}
                  </p>
                )}
              </div>

              {/* Password Field */}
              <div>
                <label
                  htmlFor="password"
                  className="block text-sm font-medium text-on-surface mb-2"
                >
                  Password
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <RiLockLine className="h-5 w-5 text-on-surface-variant" />
                  </div>
                  <input
                    id="password"
                    type="password"
                    value={data.password}
                    onChange={e => setData('password', e.target.value)}
                    className="input w-full touch-target pl-10"
                    required
                    autoComplete="new-password"
                    minLength={8}
                  />
                </div>
                <p className="mt-1 text-xs text-on-surface-variant">
                  Minimum 8 characters
                </p>
                {errors.password && (
                  <p className="mt-2 text-sm text-secondary" role="alert">
                    {errors.password}
                  </p>
                )}
              </div>

              {/* Password Confirmation Field */}
              <div>
                <label
                  htmlFor="password_confirmation"
                  className="block text-sm font-medium text-on-surface mb-2"
                >
                  Confirm password
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <RiLockLine className="h-5 w-5 text-on-surface-variant" />
                  </div>
                  <input
                    id="password_confirmation"
                    type="password"
                    value={data.password_confirmation}
                    onChange={e => setData('password_confirmation', e.target.value)}
                    className="input w-full touch-target pl-10"
                    required
                    autoComplete="new-password"
                    minLength={8}
                  />
                </div>
                {errors.password_confirmation && (
                  <p className="mt-2 text-sm text-secondary" role="alert">
                    {errors.password_confirmation}
                  </p>
                )}
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={processing || !data.role}
                className={clsx(
                  'w-full btn-primary touch-target',
                  'disabled:opacity-50 disabled:cursor-not-allowed'
                )}
              >
                {processing ? 'Creating account...' : 'Create Account'}
              </button>

              {/* Terms Notice */}
              <p className="text-xs text-on-surface-variant text-center">
                By creating an account, you agree to our Terms of Service and Privacy Policy
              </p>
            </form>
          </div>

          {/* Login Link */}
          <div className="mt-6 bg-surface-container-low rounded-md p-4 text-center">
            <p className="text-sm text-on-surface-variant">
              Already have an account?{' '}
              <Link
                href="/login"
                className="font-medium text-on-primary-fixed-variant hover:underline"
              >
                Sign in
              </Link>
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
