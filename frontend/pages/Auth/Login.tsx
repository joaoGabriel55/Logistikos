import { Head, Link, useForm } from '@inertiajs/react'
import { FormEvent } from 'react'
import { RiGoogleFill, RiMailLine, RiLockLine } from 'react-icons/ri'
import clsx from 'clsx'
import { useOAuthRedirect } from '@/hooks/useOAuthRedirect'

interface LoginProps {
  googleOAuthUrl?: string
}

export default function Login({ googleOAuthUrl }: LoginProps) {
  const { data, setData, post, processing, errors } = useForm({
    email: '',
    password: '',
    remember: false
  })

  // OAuth redirect handler using custom hook
  const handleGoogleLogin = useOAuthRedirect(googleOAuthUrl || '/auth/google_oauth2')

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    post('/login')
  }

  return (
    <>
      <Head title="Sign In" />
      <div className="min-h-screen bg-surface flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          {/* Main Card */}
          <div className="bg-surface-container-lowest rounded-md shadow-ambient p-6 sm:p-8">
            {/* Header */}
            <div className="mb-8">
              <h1 className="text-4xl font-display font-bold text-primary mb-2">
                Sign In
              </h1>
              <p className="text-sm font-body text-on-surface-variant">
                Welcome back to Logistikos
              </p>
            </div>

            {/* Google OAuth Button */}
            {googleOAuthUrl && (
              <div className="mb-6">
                <button
                  type="button"
                  onClick={handleGoogleLogin}
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
                    Or continue with email
                  </span>
                </div>
              </div>
            )}

            {/* Login Form */}
            <form onSubmit={handleSubmit} className="space-y-5">
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
                    autoFocus
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
                    autoComplete="current-password"
                  />
                </div>
                {errors.password && (
                  <p className="mt-2 text-sm text-secondary" role="alert">
                    {errors.password}
                  </p>
                )}
              </div>

              {/* Remember Me Checkbox */}
              <div className="flex items-center">
                <input
                  id="remember"
                  type="checkbox"
                  checked={data.remember}
                  onChange={e => setData('remember', e.target.checked)}
                  className={clsx(
                    'h-5 w-5 rounded border-outline-variant/50',
                    'text-primary focus:ring-2 focus:ring-primary/20'
                  )}
                />
                <label
                  htmlFor="remember"
                  className="ml-3 block text-sm text-on-surface"
                >
                  Remember me for 30 days
                </label>
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={processing}
                className={clsx(
                  'w-full btn-primary touch-target',
                  'disabled:opacity-50 disabled:cursor-not-allowed'
                )}
              >
                {processing ? 'Signing in...' : 'Sign In'}
              </button>
            </form>
          </div>

          {/* Registration Link */}
          <div className="mt-6 bg-surface-container-low rounded-md p-4 text-center">
            <p className="text-sm text-on-surface-variant">
              Don't have an account?{' '}
              <Link
                href="/register"
                className="font-medium text-on-primary-fixed-variant hover:underline"
              >
                Create one now
              </Link>
            </p>
          </div>
        </div>
      </div>
    </>
  )
}
