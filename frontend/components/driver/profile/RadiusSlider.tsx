interface RadiusSliderProps {
  value: number
  onChange: (value: number) => void
  error?: string
}

export default function RadiusSlider({ value, onChange, error }: RadiusSliderProps) {
  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    onChange(parseInt(e.target.value))
  }

  return (
    <section className="bg-surface px-4 py-6">
      <h3 className="text-headline-sm font-display font-semibold text-primary mb-2">
        Working Radius
      </h3>
      <p className="text-body-md text-on-surface-variant mb-5">
        Set the maximum distance you want to travel for pickups
      </p>

      <div className="bg-surface-container-lowest rounded-md p-6">
        {/* Current Value Display */}
        <div className="text-center mb-6">
          <div className="text-display-md font-display font-bold text-primary">
            {value}
            <span className="text-headline-md font-medium text-on-surface-variant ml-2">
              km
            </span>
          </div>
          <p className="text-label-md text-on-surface-variant mt-2">
            You'll see orders within this radius
          </p>
        </div>

        {/* Slider */}
        <div className="relative">
          <input
            type="range"
            min="5"
            max="50"
            step="5"
            value={value}
            onChange={handleChange}
            className="w-full h-2 rounded-full appearance-none cursor-pointer touch-target"
            style={{
              background: `linear-gradient(to right, #000e24 0%, #000e24 ${
                ((value - 5) / 45) * 100
              }%, #e1e2e4 ${((value - 5) / 45) * 100}%, #e1e2e4 100%)`
            }}
            aria-label="Working radius in kilometers"
          />
          {/* Range labels */}
          <div className="flex justify-between mt-2 text-label-md text-on-surface-variant">
            <span>5 km</span>
            <span>50 km</span>
          </div>
        </div>
      </div>

      {error && (
        <p className="mt-3 text-sm text-secondary" role="alert">
          {error}
        </p>
      )}
    </section>
  )
}
