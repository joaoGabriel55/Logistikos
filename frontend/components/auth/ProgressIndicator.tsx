import clsx from 'clsx'

interface StepConfig {
  number: number
  label: string
}

interface ProgressIndicatorProps {
  currentStep: number
  steps: StepConfig[]
}

export default function ProgressIndicator({ currentStep, steps }: ProgressIndicatorProps) {
  return (
    <div className="flex items-center justify-center gap-3">
      {steps.map((step, index) => (
        <div key={step.number} className="flex items-center gap-2">
          {/* Step Circle */}
          <div
            className={clsx(
              'w-10 h-10 rounded-full flex items-center justify-center font-display font-bold transition-all duration-300',
              currentStep === step.number
                ? 'bg-gradient-to-br from-primary to-primary-container text-white scale-110'
                : 'bg-surface-container-high text-on-surface-variant'
            )}
          >
            {step.number}
          </div>

          {/* Step Label */}
          <span
            className={clsx(
              'text-sm font-medium transition-colors hidden sm:inline',
              currentStep === step.number ? 'text-on-surface' : 'text-on-surface-variant'
            )}
          >
            {step.label}
          </span>

          {/* Progress Line (not shown after last step) */}
          {index < steps.length - 1 && (
            <div className="w-12 sm:w-20 h-0.5 bg-surface-container-high rounded-full overflow-hidden ml-2">
              <div
                className="h-full bg-gradient-to-r from-primary to-primary-container transition-all duration-500"
                style={{ width: currentStep > step.number ? '100%' : '0%' }}
              />
            </div>
          )}
        </div>
      ))}
    </div>
  )
}
