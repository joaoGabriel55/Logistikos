# Ticket 001: Project Scaffolding

## Description
Initialize the Rails 8 application with Inertia.js, React (TypeScript), Vite, and TailwindCSS. This is the foundation every other ticket builds on. Configure the `inertia_rails` gem, `vite_rails`, and set up the `frontend/` directory structure with all subdirectories per the PRD project structure (section 14).

## Acceptance Criteria
- [ ] Rails 8.1+ app is initialized and `rails server` boots without errors
- [ ] `inertia_rails` gem is installed and configured (`config/initializers/inertia_rails.rb`)
- [ ] `vite_rails` gem is installed, Vite dev server compiles assets
- [ ] React 18+ with TypeScript is configured as Inertia client adapter (`@inertiajs/react`)
- [ ] TailwindCSS is installed and utility classes render correctly
- [ ] `frontend/` directory structure exists: `pages/`, `components/`, `hooks/`, `layouts/`, `types/`, `entrypoints/`
- [ ] `frontend/entrypoints/application.tsx` is the Inertia app entry point
- [ ] `frontend/layouts/AppLayout.tsx` exists as the default layout
- [ ] `frontend/types/inertia.d.ts` has base Inertia type definitions
- [ ] A smoke-test Inertia page renders a React component with Tailwind classes successfully

## Dependencies
- None (this is the first ticket)

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `Gemfile` — add `inertia_rails`, `vite_rails` gems
- `package.json` — add `@inertiajs/react`, `react`, `react-dom`, `typescript`, `tailwindcss`, `vite`
- `vite.config.ts` — Vite configuration with Rails plugin
- `tsconfig.json` — TypeScript configuration
- `tailwind.config.js` — base TailwindCSS config
- `config/initializers/inertia_rails.rb` — Inertia server-side configuration
- `frontend/entrypoints/application.tsx` — Inertia app bootstrap
- `frontend/entrypoints/application.css` — Tailwind imports
- `frontend/layouts/AppLayout.tsx` — default Inertia layout
- `frontend/types/inertia.d.ts` — Inertia TypeScript declarations
- `frontend/types/models.ts` — placeholder for domain types
- `config/routes.rb` — add root route to smoke-test page

## Technical Notes
- Follow the official `inertia-rails.dev` documentation for setup
- Use Vite with the `vite_rails` gem (not Webpacker or Shakapacker)
- The `frontend/` directory is the React root — NOT `app/javascript/`
- Inertia replaces traditional ERB views entirely — no `.html.erb` files for pages
- Ensure `render inertia:` works from a test controller action
- Reference: https://inertia-rails.dev/
