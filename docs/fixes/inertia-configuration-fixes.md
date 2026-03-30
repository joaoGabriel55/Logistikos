# Inertia Configuration Fixes - 2026-03-30

## Summary
Fixed critical configuration issues preventing the Rails + Inertia.js + React application from starting. The fixes address InertiaRails 3.x API changes and Vite path resolution problems.

## Critical Issues Fixed

### 1. InertiaRails 3.x Configuration (BLOCKING)
**File:** `config/initializers/inertia_rails.rb`

**Problem:**
- Used `config.shared_data=` which doesn't exist in InertiaRails 3.x
- Referenced undefined `Current.user` class (authentication not yet implemented)
- Application crashed on startup with `undefined method 'shared_data='`

**Solution:**
- Removed `config.shared_data` configuration block
- Simplified initializer to only configure version using ViteRuby digest
- Added documentation comment noting that shared data will be added via `inertia_share` in ApplicationController once authentication is implemented (ticket 002)

**Changes:**
```ruby
# Before:
config.shared_data = lambda do
  {
    auth: { user: Current.user&.slice(:id, :email, :name, :role) },
    flash: { notice: flash[:notice], alert: flash[:alert] }
  }
end

# After:
# NOTE: Shared data configuration (auth state, flash messages, etc.) will be added
# in ApplicationController using `inertia_share` once authentication is implemented
# in ticket 002. InertiaRails 3.x does not support config.shared_data in initializers.
```

### 2. ApplicationController Shared Data Setup
**File:** `app/controllers/application_controller.rb`

**Change:**
- Added commented documentation showing the correct pattern for shared data using `inertia_share`
- Provides clear guidance for ticket 002 (authentication implementation)

```ruby
# Shared data available to all Inertia pages
# NOTE: Authentication state sharing will be added here once ticket 002
# (Rails 8 built-in authentication) is implemented:
#
# inertia_share do
#   {
#     auth: {
#       user: Current.user&.slice(:id, :email, :name, :role)
#     },
#     flash: {
#       notice: flash[:notice],
#       alert: flash[:alert]
#     }
#   }
# end
```

### 3. Vite Alias Path Resolution (BLOCKING)
**File:** `vite.config.ts`

**Problem:**
- Used absolute paths starting with `/` (e.g., `'@': '/frontend'`)
- Vite interpreted these as filesystem root paths instead of project-relative paths
- Build failed with `ENOENT: no such file or directory, open '/frontend/layouts/AppLayout.tsx'`

**Solution:**
- Import Node.js `path` module
- Use `path.resolve(__dirname, './frontend')` for proper relative path resolution
- Applied to all alias paths

**Changes:**
```typescript
// Before:
resolve: {
  alias: {
    '@': '/frontend',
    '@components': '/frontend/components',
    // ... etc
  }
}

// After:
import path from 'path'

resolve: {
  alias: {
    '@': path.resolve(__dirname, './frontend'),
    '@components': path.resolve(__dirname, './frontend/components'),
    // ... etc
  }
}
```

### 4. Vite Entrypoint Loading in Rails Layout (BLOCKING)
**File:** `app/views/layouts/application.html.erb`

**Problem:**
- Used `vite_typescript_tag 'application'` which automatically appends `.ts` extension
- Actual entrypoint file is `application.tsx` (React)
- Vite Ruby couldn't find `application.ts` in manifest, causing 500 errors

**Solution:**
- Changed to `vite_javascript_tag 'application.tsx'` with explicit `.tsx` extension
- Added `vite_react_refresh_tag` for React Fast Refresh / HMR support

**Changes:**
```erb
<!-- Before: -->
<%= vite_client_tag %>
<%= vite_typescript_tag 'application' %>

<!-- After: -->
<%= vite_client_tag %>
<%= vite_react_refresh_tag %>
<%= vite_javascript_tag 'application.tsx' %>
```

### 5. Explicit Import Extension in Entrypoint
**File:** `frontend/entrypoints/application.tsx`

**Change:**
- Made AppLayout import explicit with `.tsx` extension
- Improves clarity and avoids potential module resolution issues

```typescript
// Before:
import AppLayout from '@/layouts/AppLayout'

// After:
import AppLayout from '@/layouts/AppLayout.tsx'
```

## Verification

### Application Startup Test
```bash
bin/rails runner "puts 'Rails loaded successfully'"
# Output: Rails loaded successfully
```

### Vite Build Test
```bash
bin/vite build --clear --mode=development
# Output: ✓ built in 941ms
```

### Server HTTP Response Test
```bash
curl -s -o /dev/null -w '%{http_code}' http://localhost:3001/
# Output: 200
```

### Test Suite
```bash
bin/rails test
# Output: 0 runs, 0 assertions, 0 failures, 0 errors, 0 skips
```

## Root Cause Analysis

The issues stemmed from:

1. **API Version Mismatch**: InertiaRails 3.x changed how shared data is configured, moving from initializer-based `config.shared_data` to controller-based `inertia_share` helper.

2. **Premature Feature Reference**: Scaffolding code referenced authentication features (`Current.user`) that don't exist yet, violating the principle of implementing only what's needed for the current ticket.

3. **Vite Path Configuration**: Used filesystem-absolute paths instead of project-relative paths, a common mistake when configuring Vite aliases.

4. **Rails Helper Mismatch**: Used TypeScript-specific helper (`vite_typescript_tag`) for a React TypeScript file (`.tsx`), which has different extension handling.

## Prevention Guidelines

For future development:

1. Always check gem version documentation before using configuration APIs (InertiaRails 3.x vs 2.x)
2. Never reference features not yet implemented (authentication, Current class, etc.)
3. Use `path.resolve(__dirname, './relative/path')` for all Vite alias configurations
4. Use `vite_javascript_tag` with explicit file extensions for React entrypoints
5. Test application startup immediately after configuration changes
6. Run `bin/vite build` after Vite configuration changes to catch build issues early

## Related Documentation

- InertiaRails 3.x Upgrade Guide: https://github.com/inertiajs/inertia-rails
- Vite Ruby Configuration: https://vite-ruby.netlify.app/
- Rails 8 Built-in Authentication: (to be implemented in ticket 002)

## Files Modified

1. `/Users/quaresma/codeminer42/hackaton2026/Logistikos/config/initializers/inertia_rails.rb`
2. `/Users/quaresma/codeminer42/hackaton2026/Logistikos/app/controllers/application_controller.rb`
3. `/Users/quaresma/codeminer42/hackaton2026/Logistikos/vite.config.ts`
4. `/Users/quaresma/codeminer42/hackaton2026/Logistikos/app/views/layouts/application.html.erb`
5. `/Users/quaresma/codeminer42/hackaton2026/Logistikos/frontend/entrypoints/application.tsx`
6. `/Users/quaresma/codeminer42/hackaton2026/Logistikos/docs/reviews/ticket-001-review.md`

## Status

All critical issues resolved. Application starts successfully and serves pages with 200 HTTP status.
