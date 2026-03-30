# Ticket 004: Authentication (Rails 8 Built-in Auth + OmniAuth Google)

## Description
Set up user authentication using Rails 8 built-in authentication generator (`bin/rails generate authentication`) with OmniAuth Google strategy. This provides `has_secure_password`, a `Session` model, `Current.user` singleton, and authentication concerns — no Devise dependency. Users sign in via Google OAuth (or email/password) and are assigned a role (customer or driver). Create the Login Inertia page and configure session-based authentication that protects all routes.

## Acceptance Criteria
- [ ] Rails 8 authentication generated via `bin/rails generate authentication`
- [ ] `User` model has `has_secure_password` for password hashing (bcrypt)
- [ ] `Session` model created for session management (tracks ip_address, user_agent)
- [ ] `Current` singleton provides `Current.user` and `Current.session` access
- [ ] `Authentication` concern added to `ApplicationController` with `before_action :authenticate`
- [ ] OmniAuth Google OAuth2 strategy configured (`config/initializers/omniauth.rb`)
- [ ] `Auth::OmniauthCallbacksController` handles Google callback — creates user on first login, finds on subsequent
- [ ] User role is set during registration (customer or driver)
- [ ] Session-based authentication protects all routes (redirect to login if unauthenticated)
- [ ] Post-login redirect: customers go to dashboard/order list, drivers go to order feed
- [ ] Login page (`frontend/pages/Auth/Login.tsx`) renders with Google sign-in button and email/password form
- [ ] Login page follows DESIGN.md styling (primary gradient CTA, no borders, surface hierarchy)
- [ ] Logout functionality works — destroys session record and clears cookie
- [ ] Registration page (`frontend/pages/Auth/Register.tsx`) with role selection

## Dependencies
- **003** — User model and migration must exist

## Estimated Effort
**M** (2-3 hours)

## Files to Create/Modify
- `Gemfile` — add `omniauth-google-oauth2`, `omniauth-rails_csrf_protection`, `bcrypt`
- `config/initializers/omniauth.rb` — OmniAuth configuration
- `config/routes.rb` — session routes, OAuth callback routes, registration routes
- `app/models/user.rb` — `has_secure_password`, `from_omniauth` class method, `has_many :sessions`
- `app/models/session.rb` — session model (belongs_to :user)
- `app/models/current.rb` — `Current.user` and `Current.session` singleton
- `app/controllers/concerns/authentication.rb` — authentication concern with `authenticate` and `require_authentication`
- `app/controllers/application_controller.rb` — `include Authentication`
- `app/controllers/sessions_controller.rb` — login/logout (create/destroy sessions)
- `app/controllers/registrations_controller.rb` — user registration
- `app/controllers/auth/omniauth_callbacks_controller.rb` — Google callback handling
- `frontend/pages/Auth/Login.tsx` — Login page with Google OAuth button + email/password
- `frontend/pages/Auth/Register.tsx` — Registration page with role selection

## Technical Notes
- Rails 8 authentication generator creates: User model updates, Session model, Current singleton, Authentication concern, SessionsController, and related views
- Use `omniauth-google-oauth2` gem for the OAuth strategy
- The `from_omniauth` method on User should find_or_create by provider+uid
- For development, use OmniAuth test mode (`OmniAuth.config.test_mode = true`)
- Inertia handles the redirect after login — use `redirect_to` in the callback controller
- `Current.user` replaces Devise's `current_user` helper
- `before_action :authenticate` (from Authentication concern) replaces Devise's `authenticate_user!`
- Session is stored as a database record (not just a cookie) for better security and revocability
- Environment variables: `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`
- **No Devise gem** — Rails 8 provides everything needed out of the box
