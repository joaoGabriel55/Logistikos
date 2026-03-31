import { Link, usePage } from '@inertiajs/react'
import clsx from 'clsx'
import {
  RiGridLine,
  RiGridFill,
  RiFileListLine,
  RiFileListFill,
  RiMapPinLine,
  RiMapPinFill,
  RiUserLine,
  RiUserFill
} from 'react-icons/ri'

interface NavItem {
  name: string
  href: string
  icon: React.ElementType
  activeIcon: React.ElementType
  pattern?: RegExp
}

const navItems: NavItem[] = [
  {
    name: 'Feed',
    href: '/driver/feed',
    icon: RiGridLine,
    activeIcon: RiGridFill,
    pattern: /^\/driver\/feed/
  },
  {
    name: 'Orders',
    href: '/orders',
    icon: RiFileListLine,
    activeIcon: RiFileListFill,
    pattern: /^\/orders/
  },
  {
    name: 'Map',
    href: '/map',
    icon: RiMapPinLine,
    activeIcon: RiMapPinFill,
    pattern: /^\/map/
  },
  {
    name: 'Profile',
    href: '/profile',
    icon: RiUserLine,
    activeIcon: RiUserFill,
    pattern: /^\/profile/
  }
]

interface BottomNavProps {
  className?: string
}

export default function BottomNav({ className = '' }: BottomNavProps) {
  const { url } = usePage()

  const isActive = (item: NavItem): boolean => {
    if (item.pattern) {
      return item.pattern.test(url)
    }
    return url === item.href
  }

  return (
    <nav
      className={clsx(
        'fixed bottom-0 left-0 right-0 z-30',
        'glass shadow-ambient',
        className
      )}
      style={{
        paddingBottom: 'env(safe-area-inset-bottom)'
      }}
    >
      <div className="flex items-center justify-around h-16">
        {navItems.map((item) => {
          const active = isActive(item)
          const Icon = active ? item.activeIcon : item.icon

          return (
            <Link
              key={item.name}
              href={item.href}
              className={clsx(
                'flex flex-col items-center justify-center gap-1',
                'touch-target flex-1 py-2',
                'transition-colors'
              )}
            >
              <Icon
                className={clsx(
                  'w-6 h-6',
                  active ? 'text-secondary' : 'text-on-surface-variant'
                )}
              />
              <span
                className={clsx(
                  'text-label-md font-medium',
                  active ? 'text-secondary' : 'text-on-surface-variant'
                )}
              >
                {item.name}
              </span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
