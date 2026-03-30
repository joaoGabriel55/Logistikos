import { createRoot } from 'react-dom/client'
import { createInertiaApp } from '@inertiajs/react'
import type { ComponentType, ReactNode } from 'react'
import AppLayout from '@/layouts/AppLayout.tsx'
import './application.css'

const pages = import.meta.glob('../pages/**/*.tsx')

interface PageModule {
  default: ComponentType & {
    layout?: (children: ReactNode) => JSX.Element
  }
}

createInertiaApp({
  title: (title) => title ? `${title} - Logistikos` : 'Logistikos',
  resolve: async (name) => {
    const page = await pages[`../pages/${name}.tsx`]() as PageModule
    page.default.layout = page.default.layout || ((children: ReactNode) => <AppLayout>{children}</AppLayout>)
    return page
  },
  setup({ el, App, props }) {
    const root = createRoot(el)
    root.render(<App {...props} />)
  },
  progress: {
    color: '#a33800', // secondary color for progress bar
  }
})
