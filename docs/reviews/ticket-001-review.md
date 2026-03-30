## Code Review Report
**Branch**: main
**Files Changed**: 23 (backend: 7, frontend: 12, config: 4)
**Review Date**: 2026-03-30

### Summary
Project scaffolding implementation for the Logistikos MVP, setting up Inertia.js + React with Rails 8. The implementation establishes the foundation with TypeScript, TailwindCSS, and follows the Precision Logistikos design system.

### Critical Issues (Must Fix)

- **[RESOLVED 2026-03-30]** **[config/initializers/inertia_rails.rb:12]** CONFIGURATION: Application fails to start
  - **Risk**: Rails application crashes on startup with `undefined method 'shared_data='`
  - **Fix**: Removed `config.shared_data` from initializer. Added comment documenting where `inertia_share` will be added in ApplicationController once authentication is implemented.

- **[RESOLVED 2026-03-30]** **[config/initializers/inertia_rails.rb:15]** ARCHITECTURE: Reference to undefined Current class
  - **Risk**: Will cause runtime errors when accessing shared data
  - **Fix**: Removed all references to `Current.user`. Added commented example in ApplicationController showing the pattern to be used when ticket 002 (authentication) is implemented.

### Warnings (Should Fix)

- **[app/views/layouts/application.html.erb:22-24]** ASSET_PIPELINE: Mixed asset pipeline usage
  - **Suggestion**: Using both Propshaft (`stylesheet_link_tag`) and Vite. Choose one approach:
    - If using Vite for all assets, remove `stylesheet_link_tag :app`
    - If keeping Propshaft for some assets, document the split responsibility

- **[frontend/entrypoints/application.tsx:11]** TYPE_SAFETY: Using `any` type defeats TypeScript benefits
  - **Suggestion**: Define proper types for page modules:
    ```typescript
    interface PageModule {
      default: React.ComponentType & { layout?: (children: React.ReactNode) => React.ReactElement }
    }
    const page = await pages[`../pages/${name}.tsx`]() as PageModule
    ```

- **[frontend/pages/Home.tsx:31]** DESIGN_SYSTEM: Violates "no-border" philosophy
  - **Suggestion**: Remove `border-t border-ghost` and use spacing/background color shift instead

- **[config/initializers/content_security_policy.rb]** SECURITY: CSP is completely commented out
  - **Suggestion**: Enable and configure CSP for Vite development:
    ```ruby
    Rails.application.configure do
      config.content_security_policy do |policy|
        # ... configure policy
        policy.script_src *policy.script_src, :unsafe_eval, "http://#{ViteRuby.config.host_with_port}" if Rails.env.development?
      end
    end
    ```

- **[frontend/types/models.ts:28]** DOMAIN: Order status enum doesn't match PRD specification
  - **Suggestion**: Update to match domain statuses: `processing`, `open`, `accepted`, `pickup_in_progress`, `in_transit`, `completed`, `cancelled`, `expired`, `error`

### Suggestions (Nice to Have)

- **[package.json]**: Add scripts for type checking and linting:
  ```json
  "scripts": {
    "typecheck": "tsc --noEmit",
    "lint": "eslint frontend"
  }
  ```

- **[app/javascript/entrypoints/application.js]**: This file appears to be a leftover from vite_rails setup. Can be removed since we're using TypeScript entrypoint

- **[frontend/entrypoints/application.css:9]**: Loading fonts from Google CDN might be blocked by some users
  - Consider self-hosting fonts for better performance and privacy

- **[Procfile.dev]**: Add job runner to development procfile:
  ```
  jobs: bin/jobs
  ```

- **[tsconfig.json]**: Add `baseUrl` to complement path aliases:
  ```json
  "baseUrl": ".",
  ```

### What Looks Good

- **TailwindCSS configuration** perfectly matches the Precision Logistikos design system with all correct color values, font families, and custom utilities
- **TypeScript strict mode** is properly enabled with good compiler options
- **Vite configuration** has clean path aliases for better import organization
- **Frontend structure** follows best practices with clear separation of pages, components, layouts
- **Touch target utility class** correctly implements 44x44dp minimum size requirement
- **Glassmorphism implementation** uses correct opacity (80%) and blur (20px) values
- **Button styles** follow the design system with primary gradient, secondary action, and tertiary variants
- **Mobile-first approach** evident in the Home component's responsive design
- **Clean separation** between Inertia page components and reusable components

### Security Checklist Results

✅ No hardcoded secrets or API keys found
✅ No sensitive data exposed in shared props (though Current.user needs implementation)
✅ Input field styles defined (though no actual forms yet)
✅ CORS not configured (appropriate for this stage)
⚠️ CSP disabled - should be configured
⚠️ Current.user implementation missing - needed for auth

### Performance Checklist Results

✅ Vite configured for development with HMR
✅ Dynamic imports set up correctly for code splitting
✅ TanStack Query included for future polling implementation
✅ No N+1 query risks (no database queries yet)
✅ Minimal dependencies included

### Verdict: APPROVED_WITH_WARNINGS

The implementation provides a solid foundation and critical blocking issues have been resolved. The application now starts successfully without runtime errors. Remaining warnings are non-blocking and can be addressed in subsequent tickets.

### Priority Actions (Completed):
1. ✅ Fix InertiaRails configuration to use controller-based sharing - removed invalid config
2. ✅ Remove or implement Current class reference - removed, documented for ticket 002
3. ✅ Fix Vite alias paths - changed from absolute `/frontend` to `path.resolve(__dirname, './frontend')`
4. ✅ Fix Vite entrypoint loading - changed from `vite_typescript_tag 'application'` to `vite_javascript_tag 'application.tsx'`
5. ✅ Add React refresh tag - added `vite_react_refresh_tag` for HMR support

### Additional Fixes Applied (2026-03-30):
- **[vite.config.ts:12]** Fixed alias resolution using `path.resolve(__dirname, './frontend')` instead of absolute `/frontend` paths
- **[frontend/entrypoints/application.tsx:3]** Made import explicit with `.tsx` extension
- **[app/views/layouts/application.html.erb:24-26]** Changed from `vite_typescript_tag` to `vite_javascript_tag` with explicit `.tsx` extension, added `vite_react_refresh_tag` for React HMR

### Remaining Non-Blocking Warnings:
3. Enable and configure CSP for development
4. Fix the order status enum to match domain requirements
5. Remove the border from Home component footer
