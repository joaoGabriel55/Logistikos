## Code Review Report
**Branch**: 004/authentication
**Files Changed**: 23
**Review Date**: 2026-03-30

### Summary
Implementation of authentication system with Rails 8 built-in authentication, OAuth2 (Google), and role-based access. The implementation is mostly solid with good test coverage but has several critical security issues that must be addressed.

### Critical Issues (Must Fix)

- **[app/controllers/auth/omniauth_callbacks_controller.rb:8]** SECURITY: CSRF protection disabled without validation
  - **Risk**: Cross-site request forgery attacks possible on OAuth callback endpoint
  - **Fix**: Instead of skipping CSRF, use `omniauth-rails_csrf_protection` gem properly configured (already in Gemfile). The gem handles CSRF tokens for OAuth flows correctly.

- **[app/controllers/*/multiple files]** CODE DUPLICATION: Session creation logic duplicated across 4 controllers
  - **Risk**: Inconsistent session handling, maintenance nightmare, potential security gaps
  - **Fix**: Extract `create_session_for` and `after_login_path` methods to the Authentication concern

- **[app/controllers/application_controller.rb:1]** SECURITY: Missing explicit CSRF protection declaration
  - **Risk**: While Rails 8 enables CSRF protection by default, it should be explicitly declared
  - **Fix**: Add `protect_from_forgery with: :exception` to ApplicationController

### Warnings (Should Fix)

- **[frontend/pages/Auth/Login.tsx:59,62]** DESIGN SYSTEM: Border used for visual separation
  - **Suggestion**: Replace `border-t` with tonal surface background shift per "No-Line Rule". Use `bg-surface-container-high` for the divider area.

- **[app/controllers/registrations_controller.rb:20]** UX/SECURITY: Detailed error messages exposed to user
  - **Suggestion**: Log detailed errors server-side but show generic messages to users to prevent information disclosure

- **[app/models/session.rb:25-27]** PRIVACY: IP address hashing loses forensic value
  - **Suggestion**: Consider encrypting instead of hashing to preserve investigation capability while maintaining privacy

- **[app/controllers/auth/role_selection_controller.rb:30]** SECURITY: Random password for OAuth users stored in DB
  - **Suggestion**: Consider using `password_digest: nil` for OAuth-only users and skip `has_secure_password` validation

- **[config/initializers/omniauth.rb:5-6]** CONFIGURATION: OAuth credentials using ENV.fetch with nil default
  - **Suggestion**: Use Rails credentials (`Rails.application.credentials.google_oauth`) or raise error if missing in production

### Suggestions (Nice to Have)

- **[app/models/user.rb:37]** Consider adding index on encrypted email for performance since it's deterministic encryption

- **[frontend/pages/Auth/Register.tsx:227]** Add actual links to Terms of Service and Privacy Policy pages

- **[app/controllers/sessions_controller.rb:14]** Add rate limiting to prevent brute force attacks (consider rack-attack gem)

- **[spec/controllers/*]** Consider adding request specs in addition to controller specs for better integration testing

- **[frontend/components/ui/Button.tsx]** Button component is well-structured and follows design system

### What Looks Good

- Excellent test coverage with 77 passing tests covering all authentication scenarios
- Proper use of Rails 8's built-in authentication with `has_secure_password` and Current
- Good PII handling with encryption on User model and filter_attributes
- Correct database indexes on users.email and sessions.user_id for performance
- Touch targets properly sized (using touch-target class) meeting 44x44dp requirement
- Input heights correctly set to 56px (h-14) following design system
- Typography properly uses Manrope for headlines and Inter for body text
- Color scheme correctly implements primary (#000e24) and secondary (#a33800) usage
- Password validation enforces 8-character minimum
- Generic error messages prevent user enumeration attacks
- Session cleanup method for removing old sessions
- Proper separation of OAuth and password-based authentication flows
- Good use of Inertia.js patterns with useForm hooks and proper props

### Performance Observations

- No N+1 queries detected in controllers
- Proper indexes on frequently queried columns (email, provider+uid)
- Session lookups are optimized with direct ID lookup
- Minimal data serialization in Inertia props (only essential user data)

### Security Observations (Positive)

- bcrypt used for password hashing
- logstop gem configured for PII redaction
- OAuth integration with omniauth-rails_csrf_protection gem (needs proper configuration)
- No hardcoded secrets or API keys found
- Proper validation of user roles before creation
- Session records track IP (hashed) and user agent for security monitoring

### Privacy Compliance

- PII fields properly encrypted with Rails 8 encrypts directive
- filter_attributes declared on models with sensitive data
- No PII exposed in logs or error messages
- User agent truncated to prevent excessive data storage

### Verdict: REQUEST_CHANGES

The authentication implementation is well-structured with good test coverage and follows most security best practices. However, the CSRF protection issues and code duplication in session management need to be addressed before approval. Once these critical issues are fixed, this will be a solid authentication system ready for production use.

### Action Items
1. Fix CSRF protection on OAuth callback endpoint
2. Extract duplicated session management code to Authentication concern
3. Add explicit CSRF protection to ApplicationController
4. Replace border dividers with tonal shifts per design system
5. Consider the security and privacy suggestions for enhanced protection
