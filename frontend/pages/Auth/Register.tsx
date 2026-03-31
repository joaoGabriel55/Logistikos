import { Head, Link, useForm } from '@inertiajs/react'
import { FormEvent, useState } from 'react'
import {
  RiGoogleFill,
  RiMailLine,
  RiLockLine,
  RiUserLine,
  RiTruckLine,
  RiShoppingBag3Line,
  RiMotorbikeLine,
  RiCarLine,
  RiShipLine,
  RiArrowLeftLine,
  RiMapPin2Line
} from 'react-icons/ri'
import clsx from 'clsx'
import { UserRole, VehicleType } from '@/types/models'
import { RegistrationFormData, VehicleOptionData, RadiusOptionData, RegistrationStep } from '@/types/registration'
import { useOAuthRedirect } from '@/hooks/useOAuthRedirect'
import {
  ProgressIndicator,
  RoleCard,
  VehicleOption,
  RadiusOption,
  FormInput
} from '@/components/auth'

interface RegisterProps {
  googleOAuthUrl?: string
  errors?: Record<string, string>
}

const PROGRESS_STEPS = [
  { number: 1, label: 'Choose Role' },
  { number: 2, label: 'Your Details' }
]

const VEHICLE_OPTIONS: VehicleOptionData[] = [
  { value: 'motorcycle', label: 'Motorcycle', icon: RiMotorbikeLine, description: 'Fast & nimble' },
  { value: 'car', label: 'Car', icon: RiCarLine, description: 'Standard delivery' },
  { value: 'van', label: 'Van', icon: RiTruckLine, description: 'Medium cargo' },
  { value: 'truck', label: 'Truck', icon: RiShipLine, description: 'Large cargo' }
]

const RADIUS_OPTIONS: RadiusOptionData[] = [
  { value: '5', label: '5 km', description: 'City center' },
  { value: '10', label: '10 km', description: 'Recommended' },
  { value: '25', label: '25 km', description: 'Metropolitan' },
  { value: '50', label: '50 km', description: 'Wide range' }
]

export default function Register({ googleOAuthUrl, errors: serverErrors }: RegisterProps) {
  const [step, setStep] = useState<RegistrationStep>(1)

  const { data, setData, post, processing, errors } = useForm<RegistrationFormData>({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
    role: '',
    vehicle_type: 'car',
    radius_preference_km: '10'
  })

  const allErrors = { ...errors, ...serverErrors }
  const handleGoogleRegister = useOAuthRedirect(googleOAuthUrl || '/auth/google_oauth2')

  const handleRoleSelect = (role: UserRole) => {
    setData('role', role)
    setStep(2)
  }

  const handleBack = () => {
    setStep(1)
  }

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault()
    post('/register')
  }

  return (
    <>
      <Head title="Create Account" />
      <div className="min-h-screen bg-surface flex items-center justify-center p-4 py-8">
        <div className="w-full max-w-2xl">
          {/* Progress Indicator */}
          <div className="mb-8">
            <ProgressIndicator currentStep={step} steps={PROGRESS_STEPS} />
          </div>

          {/* Main Card with Glass Effect */}
          <div className="bg-surface-container-lowest/95 backdrop-blur-xl rounded-2xl shadow-ambient overflow-hidden">
            {/* Step 1: Role Selection */}
            {step === 1 && (
              <div className="p-6 sm:p-10 animate-fade-in">
                {/* Header */}
                <div className="mb-10 text-center">
                  <h1 className="text-5xl sm:text-6xl font-display font-bold text-primary mb-3 tracking-tight">
                    Join Logistikos
                  </h1>
                  <p className="text-lg font-body text-on-surface-variant max-w-md mx-auto">
                    Choose how you want to use our platform
                  </p>
                </div>

                {/* Google OAuth Button */}
                {googleOAuthUrl && (
                  <>
                    <button
                      type="button"
                      onClick={handleGoogleRegister}
                      className={clsx(
                        'w-full flex items-center justify-center gap-3 mb-8',
                        'bg-surface-container-highest hover:bg-surface-container-high',
                        'transition-all duration-200 py-4 px-6 rounded-xl',
                        'font-medium text-on-surface touch-target',
                        'hover:shadow-md hover:scale-[1.02] active:scale-[0.98]'
                      )}
                    >
                      <RiGoogleFill className="w-6 h-6" />
                      Continue with Google
                    </button>

                    {/* Divider */}
                    <div className="relative mb-8">
                      <div className="absolute inset-0 flex items-center">
                        <div className="w-full border-t border-surface-container-high"></div>
                      </div>
                      <div className="relative flex justify-center text-sm">
                        <span className="px-4 bg-surface-container-lowest text-on-surface-variant font-medium">
                          Or choose your role
                        </span>
                      </div>
                    </div>
                  </>
                )}

                {/* Role Selection Cards */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-6">
                  <RoleCard
                    title="I'm a Customer"
                    description="Send packages and track deliveries in real-time"
                    icon={RiShoppingBag3Line}
                    actionText="Get Started"
                    colorScheme="primary"
                    onClick={() => handleRoleSelect('customer')}
                  />
                  <RoleCard
                    title="I'm a Driver"
                    description="Earn money by delivering packages on your schedule"
                    icon={RiTruckLine}
                    actionText="Start Earning"
                    colorScheme="secondary"
                    onClick={() => handleRoleSelect('driver')}
                  />
                </div>

                {/* Role Error */}
                {allErrors.role && (
                  <p className="mt-4 text-sm text-secondary text-center" role="alert">
                    {allErrors.role}
                  </p>
                )}
              </div>
            )}

            {/* Step 2: Registration Form */}
            {step === 2 && (
              <div className="p-6 sm:p-10 animate-fade-in">
                {/* Back Button */}
                <button
                  type="button"
                  onClick={handleBack}
                  className="flex items-center gap-2 text-on-surface-variant hover:text-on-surface transition-colors mb-6 group"
                >
                  <RiArrowLeftLine className="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
                  <span className="text-sm font-medium">Change role</span>
                </button>

                {/* Header */}
                <div className="mb-8">
                  <h2 className="text-4xl font-display font-bold text-primary mb-2">
                    {data.role === 'customer' ? 'Customer Details' : 'Driver Details'}
                  </h2>
                  <p className="text-sm font-body text-on-surface-variant">
                    {data.role === 'customer'
                      ? 'Create your account to start sending packages'
                      : 'Set up your driver profile and start earning'}
                  </p>
                </div>

                {/* Registration Form */}
                <form onSubmit={handleSubmit} className="space-y-6">
                  {/* Name Field */}
                  <FormInput
                    id="name"
                    label="Full name"
                    type="text"
                    value={data.name}
                    onChange={e => setData('name', e.target.value)}
                    icon={RiUserLine}
                    error={allErrors.name}
                    autoComplete="name"
                    autoFocus
                    required
                  />

                  {/* Email Field */}
                  <FormInput
                    id="email"
                    label="Email address"
                    type="email"
                    value={data.email}
                    onChange={e => setData('email', e.target.value)}
                    icon={RiMailLine}
                    error={allErrors.email}
                    autoComplete="email"
                    required
                  />

                  {/* Password Field */}
                  <FormInput
                    id="password"
                    label="Password"
                    type="password"
                    value={data.password}
                    onChange={e => setData('password', e.target.value)}
                    icon={RiLockLine}
                    error={allErrors.password}
                    autoComplete="new-password"
                    helperText="Minimum 8 characters"
                    minLength={8}
                    required
                  />

                  {/* Password Confirmation Field */}
                  <FormInput
                    id="password_confirmation"
                    label="Confirm password"
                    type="password"
                    value={data.password_confirmation}
                    onChange={e => setData('password_confirmation', e.target.value)}
                    icon={RiLockLine}
                    error={allErrors.password_confirmation}
                    autoComplete="new-password"
                    minLength={8}
                    required
                  />

                  {/* Driver-Specific Fields */}
                  {data.role === 'driver' && (
                    <>
                      {/* Vehicle Type Selection */}
                      <div>
                        <label className="block text-sm font-medium text-on-surface mb-3">
                          Vehicle type
                        </label>
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                          {VEHICLE_OPTIONS.map((option) => (
                            <VehicleOption
                              key={option.value}
                              option={option}
                              isSelected={data.vehicle_type === option.value}
                              onSelect={(value) => setData('vehicle_type', value as VehicleType)}
                            />
                          ))}
                        </div>
                        {allErrors.vehicle_type && (
                          <p className="mt-2 text-sm text-secondary" role="alert">
                            {allErrors.vehicle_type}
                          </p>
                        )}
                      </div>

                      {/* Radius Preference */}
                      <div>
                        <label className="block text-sm font-medium text-on-surface mb-3">
                          <div className="flex items-center gap-2">
                            <RiMapPin2Line className="w-5 h-5 text-on-surface-variant" />
                            Delivery radius
                          </div>
                        </label>
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                          {RADIUS_OPTIONS.map((option) => (
                            <RadiusOption
                              key={option.value}
                              option={option}
                              isSelected={data.radius_preference_km === option.value}
                              onSelect={(value) => setData('radius_preference_km', value)}
                            />
                          ))}
                        </div>
                        <p className="mt-2 text-xs text-on-surface-variant">
                          You'll receive delivery requests within this range from your location
                        </p>
                        {allErrors.radius_preference_km && (
                          <p className="mt-2 text-sm text-secondary" role="alert">
                            {allErrors.radius_preference_km}
                          </p>
                        )}
                      </div>
                    </>
                  )}

                  {/* Submit Button */}
                  <button
                    type="submit"
                    disabled={processing}
                    className={clsx(
                      'w-full btn-primary touch-target text-lg font-semibold',
                      'shadow-lg hover:shadow-xl transition-all duration-200',
                      'disabled:opacity-50 disabled:cursor-not-allowed',
                      'hover:scale-[1.02] active:scale-[0.98]'
                    )}
                  >
                    {processing ? 'Creating account...' : 'Create Account'}
                  </button>

                  {/* Terms Notice */}
                  <p className="text-xs text-on-surface-variant text-center leading-relaxed">
                    By creating an account, you agree to our{' '}
                    <a href="#" className="text-on-primary-fixed-variant hover:underline">Terms of Service</a>
                    {' '}and{' '}
                    <a href="#" className="text-on-primary-fixed-variant hover:underline">Privacy Policy</a>
                  </p>
                </form>
              </div>
            )}
          </div>

          {/* Login Link */}
          <div className="mt-6 bg-surface-container-low/80 backdrop-blur-sm rounded-xl p-5 text-center">
            <p className="text-sm text-on-surface-variant">
              Already have an account?{' '}
              <Link
                href="/login"
                className="font-semibold text-on-primary-fixed-variant hover:underline transition-colors"
              >
                Sign in
              </Link>
            </p>
          </div>
        </div>
      </div>

      <style>{`
        @keyframes fade-in {
          from {
            opacity: 0;
            transform: translateY(10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .animate-fade-in {
          animation: fade-in 0.4s ease-out;
        }
      `}</style>
    </>
  )
}
