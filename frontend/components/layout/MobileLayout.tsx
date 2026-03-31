import { ReactNode } from 'react'
import clsx from 'clsx'

interface MobileLayoutProps {
  children: ReactNode
  className?: string
  withBottomNav?: boolean
  withTopBar?: boolean
}

export default function MobileLayout({
  children,
  className = '',
  withBottomNav = false,
  withTopBar = false
}: MobileLayoutProps) {
  return (
    <div className="min-h-screen bg-surface flex flex-col">
      <main
        className={clsx(
          'flex-1 overflow-y-auto',
          withTopBar && 'pt-16',
          withBottomNav && 'pb-20',
          className
        )}
        style={{
          paddingBottom: withBottomNav ? 'calc(5rem + env(safe-area-inset-bottom))' : undefined,
          paddingTop: withTopBar ? 'calc(4rem + env(safe-area-inset-top))' : undefined
        }}
      >
        {children}
      </main>
    </div>
  )
}
