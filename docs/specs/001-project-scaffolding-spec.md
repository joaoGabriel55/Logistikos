# Product Specification: Project Scaffolding
**Spec ID**: 001-project-scaffolding-spec
**Status**: Draft
**Created**: 2026-03-30
**Priority**: P0 - Foundation
**Type**: Infrastructure Setup

---

## 1. Feature Overview

### Executive Summary
Establish the foundational technical infrastructure for Logistikos by integrating Inertia.js with React/TypeScript as the view layer for the Rails 8.1.3+ application. This creates a modern, single-page application (SPA) experience while leveraging Rails' mature backend capabilities for the supply-driven logistics marketplace.

### Business Value
- **Developer Velocity**: Modern frontend tooling (Vite, TypeScript, TailwindCSS) enables rapid UI development with hot module replacement and type safety
- **User Experience**: SPA-like navigation without full page refreshes, improving perceived performance for drivers on mobile devices
- **Maintainability**: Clear separation between backend (Rails) and frontend (React) with type-safe contracts via Inertia props
- **Design System Ready**: TailwindCSS setup enables immediate implementation of the "Precision Logistikos" design system

### Technical Context
This scaffolding replaces traditional Rails ERB views entirely with React components rendered via Inertia.js. The `frontend/` directory becomes the single source of truth for all UI components, following a structure optimized for the Logistikos domain.

---

## 2. Acceptance Criteria

### Core Infrastructure
- [ ] **Given** a fresh Rails 8.1.3+ application, **When** running `rails server`, **Then** the server starts without errors and serves on port 3000
- [ ] **Given** the development environment, **When** running `bin/vite dev`, **Then** the Vite dev server starts and provides hot module replacement on port 5173
- [ ] **Given** a browser request to the root path, **When** the page loads, **Then** it renders a React component via Inertia.js without any console errors

### Package Management
- [ ] **Given** the Gemfile, **When** running `bundle install`, **Then** `inertia_rails` (>= 3.0) and `vite_rails` (>= 3.0) gems are installed successfully
- [ ] **Given** the package.json, **When** running `npm install`, **Then** all frontend dependencies install without peer dependency warnings:
  - `@inertiajs/react` (>= 1.0)
  - `react` (>= 18.0) and `react-dom` (>= 18.0)
  - `typescript` (>= 5.0)
  - `@types/react` and `@types/react-dom`
  - `tailwindcss` (>= 3.4)
  - `vite` (>= 5.0)
  - `@vitejs/plugin-react`

### Configuration Files
- [ ] **Given** the TypeScript compiler, **When** running `npx tsc --noEmit`, **Then** type checking passes without errors
- [ ] **Given** a TailwindCSS utility class in a React component, **When** the page renders, **Then** the styles are applied correctly
- [ ] **Given** the Inertia Rails initializer, **When** a controller calls `render inertia:`, **Then** the correct React component receives the serialized props

### Directory Structure
- [ ] **Given** the project root, **When** inspecting the filesystem, **Then** the `frontend/` directory exists with all required subdirectories:
  - `frontend/pages/` — Inertia page components
  - `frontend/components/` — Reusable UI components
  - `frontend/hooks/` — Custom React hooks
  - `frontend/layouts/` — Page layout wrappers
  - `frontend/types/` — TypeScript type definitions
  - `frontend/entrypoints/` — Vite entry points
  - `frontend/lib/` — Utility functions and helpers
  - `frontend/styles/` — Global styles and Tailwind imports

### Entry Points and Layouts
- [ ] **Given** `frontend/entrypoints/application.tsx`, **When** Vite builds, **Then** it creates the main JavaScript bundle that bootstraps the Inertia app
- [ ] **Given** `frontend/entrypoints/application.css`, **When** processed, **Then** it includes Tailwind directives (@tailwind base/components/utilities)
- [ ] **Given** `frontend/layouts/AppLayout.tsx`, **When** any Inertia page renders, **Then** it wraps the page component with the default layout

### Type Safety
- [ ] **Given** `frontend/types/inertia.d.ts`, **When** importing Inertia types, **Then** TypeScript recognizes page props and shared data interfaces
- [ ] **Given** `frontend/types/models.ts`, **When** referenced in components, **Then** it provides type definitions for core domain entities (User, DeliveryOrder, Driver)

### Smoke Test
- [ ] **Given** a test controller with action `render inertia: 'Test/Welcome', props: { message: 'Hello Logistikos' }`, **When** navigating to that route, **Then** the React component at `frontend/pages/Test/Welcome.tsx` renders with the message prop
- [ ] **Given** the Welcome component uses Tailwind classes, **When** rendered, **Then** the styles apply correctly (e.g., `bg-primary text-white p-4`)
- [ ] **Given** the Welcome component is wrapped in AppLayout, **When** rendered, **Then** the layout chrome appears around the page content

---

## 3. Technical Requirements

### Backend Configuration

#### Gemfile Additions
```ruby
# Inertia.js adapter for Rails
gem 'inertia_rails', '~> 3.1'

# Vite integration for Rails
gem 'vite_rails', '~> 3.0'
```

#### Inertia Rails Initializer (`config/initializers/inertia_rails.rb`)
```ruby
InertiaRails.configure do |config|
  # Use Vite helper for asset versioning
  config.version = ViteRuby.digest

  # Shared data available to all pages
  config.shared_data = lambda do
    {
      auth: {
        user: Current.user&.slice(:id, :email, :name, :role)
      },
      flash: {
        notice: flash[:notice],
        alert: flash[:alert]
      }
    }
  end
end
```

### Frontend Configuration

#### Package Dependencies
```json
{
  "dependencies": {
    "@inertiajs/react": "^1.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@tanstack/react-query": "^5.0.0",
    "axios": "^1.6.0",
    "clsx": "^2.1.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@vitejs/plugin-react": "^4.2.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.3.0",
    "vite": "^5.0.0",
    "vite-plugin-ruby": "^3.2.0"
  }
}
```

#### Vite Configuration (`vite.config.ts`)
```typescript
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    react()
  ],
  resolve: {
    alias: {
      '@': '/frontend',
      '@components': '/frontend/components',
      '@pages': '/frontend/pages',
      '@hooks': '/frontend/hooks',
      '@types': '/frontend/types',
      '@lib': '/frontend/lib'
    }
  }
})
```

#### TypeScript Configuration (`tsconfig.json`)
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "paths": {
      "@/*": ["./frontend/*"],
      "@components/*": ["./frontend/components/*"],
      "@pages/*": ["./frontend/pages/*"],
      "@hooks/*": ["./frontend/hooks/*"],
      "@types/*": ["./frontend/types/*"],
      "@lib/*": ["./frontend/lib/*"]
    }
  },
  "include": ["frontend/**/*"],
  "exclude": ["node_modules", "public", "tmp", "vendor"]
}
```

#### Tailwind Configuration (`tailwind.config.js`)
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './frontend/**/*.{js,ts,jsx,tsx}',
    './app/views/**/*.html.erb'
  ],
  theme: {
    extend: {
      colors: {
        // Precision Logistikos Design System
        primary: '#000e24',
        'primary-container': '#00234b',
        secondary: '#a33800',
        'secondary-fixed': '#ffdbce',
        surface: '#f8f9fb',
        'surface-container-low': '#f3f4f6',
        'surface-container-lowest': '#ffffff',
        'surface-container-high': '#e7e8ea',
        'surface-container-highest': '#e1e2e4',
        'surface-dim': '#d9dadc',
        'surface-tint': '#455f8a',
        'on-surface': '#191c1e',
        'on-surface-variant': '#43474e',
        'on-primary-fixed-variant': '#2c4771',
        'tertiary-container': '#001f5a',
        'on-tertiary-container': '#5384ff',
        'outline-variant': '#c4c6d0'
      },
      fontFamily: {
        display: ['Manrope', 'sans-serif'],
        body: ['Inter', 'sans-serif']
      },
      borderRadius: {
        md: '0.75rem'
      },
      spacing: {
        '5': '1.1rem',
        '8': '1.75rem'
      }
    }
  },
  plugins: []
}
```

### Application Entry Point (`frontend/entrypoints/application.tsx`)
```typescript
import { createRoot } from 'react-dom/client'
import { createInertiaApp } from '@inertiajs/react'
import { resolvePageComponent } from 'vite-plugin-ruby/inertia/react'
import AppLayout from '@/layouts/AppLayout'
import './application.css'

createInertiaApp({
  title: (title) => `${title} - Logistikos`,
  resolve: (name) => {
    const page = resolvePageComponent(
      `../pages/${name}.tsx`,
      import.meta.glob('../pages/**/*.tsx')
    )
    page.then((module: any) => {
      module.default.layout = module.default.layout || ((page: any) => <AppLayout>{page}</AppLayout>)
    })
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
```

---

## 4. File Manifest

### Files to Create

| File Path | Purpose |
|---|---|
| `frontend/entrypoints/application.tsx` | Inertia app bootstrap and configuration |
| `frontend/entrypoints/application.css` | Tailwind CSS imports and global styles |
| `frontend/layouts/AppLayout.tsx` | Default layout wrapper for all pages |
| `frontend/types/inertia.d.ts` | TypeScript declarations for Inertia |
| `frontend/types/models.ts` | Domain model type definitions |
| `frontend/pages/Test/Welcome.tsx` | Smoke test component |
| `frontend/components/.gitkeep` | Placeholder for components directory |
| `frontend/hooks/.gitkeep` | Placeholder for hooks directory |
| `frontend/lib/.gitkeep` | Placeholder for utilities directory |
| `frontend/styles/.gitkeep` | Placeholder for additional styles |
| `config/initializers/inertia_rails.rb` | Inertia server configuration |
| `vite.config.ts` | Vite bundler configuration |
| `tsconfig.json` | TypeScript compiler configuration |
| `tailwind.config.js` | TailwindCSS configuration |
| `postcss.config.js` | PostCSS configuration for Tailwind |

### Files to Modify

| File Path | Changes |
|---|---|
| `Gemfile` | Add `inertia_rails` and `vite_rails` gems |
| `package.json` | Add all React, TypeScript, and build dependencies |
| `config/routes.rb` | Add root route for smoke test |
| `app/controllers/application_controller.rb` | Include Inertia module |
| `.gitignore` | Add node_modules, dist, .vite patterns |
| `Procfile.dev` | Add Vite dev server command |

---

## 5. Implementation Guidelines

### Order of Operations
1. **Install Rails gems** — Add to Gemfile and run `bundle install`
2. **Initialize Vite** — Run `bundle exec vite install`
3. **Setup npm packages** — Create package.json and run `npm install`
4. **Configure TypeScript** — Create tsconfig.json with strict mode
5. **Configure TailwindCSS** — Setup config and PostCSS
6. **Create directory structure** — Build out frontend/ tree
7. **Setup Inertia** — Create initializer and application.tsx
8. **Create smoke test** — Simple page to verify integration
9. **Test the stack** — Ensure HMR, types, and styles work

### Development Workflow Verification
After setup, developers should be able to:
1. Run `bin/dev` to start Rails + Vite dev servers
2. Make changes to React components and see instant HMR updates
3. Use TypeScript for type safety without build errors
4. Apply Tailwind classes that render correctly
5. Create new Inertia pages that receive Rails controller props

### Performance Considerations
- Vite provides fast cold starts and instant HMR
- React 18 with concurrent features for better UX
- TailwindCSS JIT mode for minimal CSS bundle size
- TypeScript for catching errors at compile time

### Security Notes
- Inertia automatically handles CSRF protection
- Props are JSON-serialized, preventing XSS
- Shared data lambda ensures sensitive data isn't leaked
- Vite manifest provides asset integrity

---

## 6. Testing Requirements

### Manual Testing Script
1. Start development servers: `bin/dev`
2. Navigate to http://localhost:3000
3. Verify the Welcome page renders with Tailwind styles
4. Open browser console — no errors should appear
5. Edit `frontend/pages/Test/Welcome.tsx` and save
6. Verify HMR updates the page without refresh
7. Add an invalid TypeScript type — verify build fails
8. Fix the type error — verify build succeeds

### Automated Tests (Future)
- Jest + React Testing Library for component tests
- Playwright or Cypress for E2E tests
- GitHub Actions CI to run type checking on PRs

---

## 7. Dependencies and Blockers

### Dependencies
- **Rails 8.1.3+** must be installed and initialized
- **Node.js 20+** and **npm 10+** required for frontend tooling
- **Ruby 3.4.3** as specified in project requirements

### Blockers
- None — this is the foundational ticket that unblocks all UI work

### Risks
- **Version conflicts** — Ensure gem and npm package versions are compatible
- **Build complexity** — Two build systems (Rails + Vite) may confuse new developers
- **Type definitions** — May need to create custom types for Rails models

---

## 8. Success Metrics

### Immediate (Development Phase)
- Zero console errors on page load
- HMR updates in < 100ms
- TypeScript compilation in < 2 seconds
- All acceptance criteria passing

### Long-term (Post-Launch)
- Developer onboarding time < 30 minutes
- Component reusability > 70%
- Type coverage > 95%
- Lighthouse performance score > 90

---

## 9. Notes for Implementers

### Why Inertia.js?
Inertia provides the best of both worlds: Rails' mature backend with React's modern UI capabilities, without the complexity of a separate API. This is ideal for the 2-week competition timeline.

### Why frontend/ instead of app/javascript/?
The `frontend/` directory clearly separates UI code from Rails code, making it easier for developers to navigate. It also aligns with modern frontend project structures.

### Why Vite over Webpack?
Vite provides significantly faster build times and better developer experience with native ES modules and hot module replacement. This accelerates development during the competition.

### Design System Integration
With TailwindCSS configured with the Precision Logistikos color palette and typography, developers can immediately start building UI that matches the design specification without manual CSS.

---

## Appendix: Example Smoke Test Component

```typescript
// frontend/pages/Test/Welcome.tsx
import { Head } from '@inertiajs/react'

interface WelcomeProps {
  message: string
}

export default function Welcome({ message }: WelcomeProps) {
  return (
    <>
      <Head title="Welcome" />
      <div className="min-h-screen bg-surface flex items-center justify-center">
        <div className="bg-surface-container-lowest p-8 rounded-md shadow-lg max-w-md">
          <h1 className="text-3xl font-display font-bold text-primary mb-4">
            Logistikos
          </h1>
          <p className="text-body text-on-surface-variant">
            {message}
          </p>
          <div className="mt-6">
            <button className="w-full bg-gradient-to-r from-primary to-primary-container text-white py-3 px-4 rounded-md font-medium hover:opacity-90 transition-opacity">
              Get Started
            </button>
          </div>
        </div>
      </div>
    </>
  )
}
```

```ruby
# app/controllers/test_controller.rb
class TestController < ApplicationController
  def welcome
    render inertia: 'Test/Welcome', props: {
      message: 'Your supply-driven logistics marketplace is ready.'
    }
  end
end
```

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'test#welcome'
end
```