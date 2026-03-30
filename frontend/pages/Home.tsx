import { Head } from '@inertiajs/react'

export default function Home() {
  return (
    <>
      <Head title="Welcome" />
      <div className="min-h-screen bg-surface flex items-center justify-center p-4">
        <div className="bg-surface-container-lowest p-8 rounded-md shadow-ambient max-w-md w-full">
          <h1 className="text-4xl font-display font-bold text-primary mb-2">
            Logistikos
          </h1>
          <p className="text-sm font-body text-secondary mb-6">
            Supply-Driven Logistics Marketplace
          </p>
          <p className="text-base font-body text-on-surface-variant mb-8">
            Welcome to Logistikos, the modern platform connecting customers who need deliveries with independent drivers.
          </p>

          <div className="space-y-4">
            <button className="w-full btn-primary touch-target">
              Get Started as Customer
            </button>
            <button className="w-full btn-action touch-target">
              Join as Driver
            </button>
            <button className="w-full btn-tertiary touch-target text-center">
              Learn More
            </button>
          </div>

          <div className="mt-8 pt-6 bg-surface-container-low -mx-8 px-8 pb-0">
            <div className="flex items-center justify-between text-xs text-on-surface-variant">
              <span>Powered by Inertia.js + React</span>
              <span className="px-2 py-1 bg-tertiary-container text-on-tertiary-container rounded">
                MVP
              </span>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
