import { Head, Link } from '@inertiajs/react'
import MobileLayout from '@/components/layout/MobileLayout'
import Button from '@/components/ui/Button'

export default function Forbidden() {
  return (
    <>
      <Head title="Access Denied" />
      <MobileLayout className="bg-surface-container-low">
        <div className="min-h-screen flex flex-col items-center justify-center px-4 py-16">
          <div className="w-24 h-24 bg-error/10 rounded-full flex items-center justify-center mb-6">
            <svg
              className="w-12 h-12 text-error"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
          </div>

          <h1 className="text-display-small text-on-surface font-manrope mb-3 text-center">
            Access Denied
          </h1>

          <p className="text-body-large text-on-surface-variant text-center mb-8 max-w-md">
            You don't have permission to access this page. Please make sure you're logged in
            with the correct account type.
          </p>

          <div className="space-y-3 w-full max-w-sm">
            <Link href="/">
              <Button variant="primary" fullWidth>
                Go to Home
              </Button>
            </Link>
            <Link href="/logout" method="delete" as="button">
              <Button variant="secondary" fullWidth>
                Sign Out
              </Button>
            </Link>
          </div>
        </div>
      </MobileLayout>
    </>
  )
}
