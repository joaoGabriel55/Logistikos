import type { User } from './models'

declare module '@inertiajs/react' {
  export interface PageProps {
    auth: {
      user: User | null
    }
    flash: {
      notice?: string
      alert?: string
    }
  }
}
