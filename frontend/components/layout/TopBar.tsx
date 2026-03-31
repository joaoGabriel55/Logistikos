import { ReactNode } from 'react'
import { Link } from '@inertiajs/react'
import clsx from 'clsx'
import { RiArrowLeftLine, RiMenuLine } from 'react-icons/ri'

interface TopBarProps {
  title: string
  showBack?: boolean
  onBack?: () => void
  backHref?: string
  rightAction?: ReactNode
  showMenu?: boolean
  onMenuClick?: () => void
  className?: string
}

export default function TopBar({
  title,
  showBack = false,
  onBack,
  backHref,
  rightAction,
  showMenu = false,
  onMenuClick,
  className = ''
}: TopBarProps) {
  const handleBack = () => {
    if (onBack) {
      onBack()
    } else if (backHref) {
      // Handled by Link component
    } else {
      window.history.back()
    }
  }

  return (
    <header
      className={clsx(
        'fixed top-0 left-0 right-0 z-30',
        'glass',
        'px-4 h-16 flex items-center justify-between',
        className
      )}
      style={{
        paddingTop: 'env(safe-area-inset-top)'
      }}
    >
      {/* Left Action */}
      <div className="flex items-center touch-target">
        {showBack && (
          backHref ? (
            <Link
              href={backHref}
              className="flex items-center justify-center w-10 h-10 -ml-2 text-on-surface hover:text-primary transition-colors"
            >
              <RiArrowLeftLine className="w-6 h-6" />
            </Link>
          ) : (
            <button
              onClick={handleBack}
              className="flex items-center justify-center w-10 h-10 -ml-2 text-on-surface hover:text-primary transition-colors"
              aria-label="Go back"
            >
              <RiArrowLeftLine className="w-6 h-6" />
            </button>
          )
        )}
        {showMenu && (
          <button
            onClick={onMenuClick}
            className="flex items-center justify-center w-10 h-10 -ml-2 text-on-surface hover:text-primary transition-colors"
            aria-label="Open menu"
          >
            <RiMenuLine className="w-6 h-6" />
          </button>
        )}
      </div>

      {/* Title */}
      <h1 className="flex-1 text-center font-display text-lg font-semibold text-on-surface truncate mx-4">
        {title}
      </h1>

      {/* Right Action */}
      <div className="flex items-center touch-target">
        {rightAction}
      </div>
    </header>
  )
}
