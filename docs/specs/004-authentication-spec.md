# Product Specification: Authentication System
**Feature ID:** 004
**Feature Name:** User Authentication with Rails 8 Built-in Auth + Google OAuth
**Date:** 2026-03-30
**Status:** Ready for Development

---

## 1. Problem Statement

Logistikos requires a secure, user-friendly authentication system that supports two distinct user types (Customers and Drivers) while maintaining privacy-by-design principles. Users need multiple sign-in options (Google OAuth and email/password) with role-based post-login routing. The system must protect all routes while providing a smooth onboarding experience for new users during the competitive 2-week development period.

---

## 2. Goals & Success Metrics

### Goals
- Implement secure, session-based authentication using Rails 8's built-in authentication generator
- Support both social login (Google OAuth) and traditional email/password authentication
- Enable role-based user registration (Customer or Driver selection)
- Protect all application routes with authentication requirements
- Implement privacy-conscious user data handling from day one

### Success Metrics
- 100% of routes protected by authentication (except login/registration pages)
- < 3 seconds for complete authentication flow (login to dashboard redirect)
- Zero PII exposure in logs or error reports
- Successful Google OAuth integration in both development and production
- Clear role differentiation post-login (Customers see order dashboard, Drivers see order feed)

---

## 3. User Personas

### Customer Persona
- **Who:** Individual or business needing delivery services
- **Authentication Needs:** Quick sign-up, minimal friction, prefers social login
- **Post-Login Expectation:** Immediate access to create delivery orders or view existing orders

### Driver Persona
- **Who:** Independent driver or small logistics business operator
- **Authentication Needs:** Professional onboarding, clear role selection, account security
- **Post-Login Expectation:** Direct access to available order feed to start earning

---

## 4. Feature Requirements

### [AUTH-001] User Registration with Role Selection
**As a** new user
**I want** to create an account with my chosen role
**So that** I can access the appropriate features for my needs

#### Acceptance Criteria
- [ ] Given I am on the registration page, When I view the form, Then I see role selection (Customer or Driver) as a required field
- [ ] Given I select "Customer" role, When I complete registration, Then my account is created with `role: 'customer'`
- [ ] Given I select "Driver" role, When I complete registration, Then my account is created with `role: 'driver'`
- [ ] Given I submit the form with valid data, When registration succeeds, Then I am automatically logged in and redirected to my role-specific dashboard
- [ ] Given I submit invalid data, When validation fails, Then I see inline error messages following the Precision Logistikos design system

#### Domain Constraints
- **User roles:** Customer, Driver (mutually exclusive, set once during registration)
- **Map implications:** None during registration
- **AI feature:** None

#### Technical Notes
- Uses `RegistrationsController#create` with Rails 8 authentication patterns
- Strong parameters include: email, password, password_confirmation, name, role
- User model validates role inclusion in ['customer', 'driver']
- Inertia page: `frontend/pages/Auth/Register.tsx`
- Form follows "no borders" rule from DESIGN.md - uses surface hierarchy

#### Priority: Must
#### Story Points: 3

---

### [AUTH-002] Email/Password Login
**As a** registered user
**I want** to sign in with my email and password
**So that** I can access my account securely

#### Acceptance Criteria
- [ ] Given I am on the login page, When I enter valid credentials, Then I am authenticated and redirected based on my role
- [ ] Given I am a Customer, When I successfully login, Then I am redirected to `/customer/dashboard` or `/customer/orders`
- [ ] Given I am a Driver, When I successfully login, Then I am redirected to `/driver/orders` (order feed)
- [ ] Given I enter invalid credentials, When I submit, Then I see a generic error message "Invalid email or password" (no user enumeration)
- [ ] Given I am already logged in, When I visit the login page, Then I am redirected to my dashboard

#### Domain Constraints
- **User roles:** Customer redirected to order creation/list, Driver redirected to order feed
- **Map implications:** None during login
- **AI feature:** None

#### Technical Notes
- `SessionsController#create` uses `has_secure_password` authentication
- Creates `Session` record with IP address and user agent for security auditing
- Sets `Current.user` via Authentication concern
- Inertia page: `frontend/pages/Auth/Login.tsx`
- Password field uses `type="password"` with secure handling

#### Priority: Must
#### Story Points: 2

---

### [AUTH-003] Google OAuth Sign-In
**As a** user
**I want** to sign in with my Google account
**So that** I can access the platform without managing another password

#### Acceptance Criteria
- [ ] Given I am on the login page, When I click "Sign in with Google", Then I am redirected to Google OAuth consent screen
- [ ] Given I authorize the app on Google, When callback completes, Then my account is found or created based on Google UID
- [ ] Given this is my first Google login, When account is created, Then I am prompted to select my role (Customer or Driver)
- [ ] Given I am a returning Google user, When I sign in, Then I am redirected to my role-specific dashboard
- [ ] Given Google OAuth fails, When callback errors, Then I see a friendly error message and can try email/password

#### Domain Constraints
- **User roles:** First-time OAuth users must select role; returning users maintain existing role
- **Map implications:** None
- **AI feature:** None

#### Technical Notes
- OmniAuth Google OAuth2 strategy configured in `config/initializers/omniauth.rb`
- `Auth::OmniauthCallbacksController#google_oauth2` handles callback
- `User.from_omniauth(auth_hash)` finds or creates user by provider + uid
- Environment variables: `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`
- Development uses `OmniAuth.config.test_mode = true` for testing
- CSRF protection via `omniauth-rails_csrf_protection` gem

#### Priority: Must
#### Story Points: 3

---

### [AUTH-004] Session Management & Logout
**As a** logged-in user
**I want** to securely end my session
**So that** others cannot access my account on shared devices

#### Acceptance Criteria
- [ ] Given I am logged in, When I click "Logout", Then my session is destroyed and I am redirected to login
- [ ] Given I logout, When session is destroyed, Then the Session record is deleted from database
- [ ] Given I logout, When I try to access protected routes, Then I am redirected to login page
- [ ] Given my session expires (after 30 days), When I access the app, Then I must re-authenticate
- [ ] Given I am logged in on multiple devices, When I logout on one, Then other sessions remain active

#### Domain Constraints
- **User roles:** Both Customer and Driver
- **Map implications:** Active map tracking stops on logout
- **AI feature:** None

#### Technical Notes
- `SessionsController#destroy` removes Session record and clears cookie
- Session model tracks: user_id, ip_address, user_agent, created_at
- Sessions expire after 30 days (configurable)
- `Current.reset` clears thread-local user reference
- Logout link in navigation header (mobile and desktop)

#### Priority: Must
#### Story Points: 2

---

### [AUTH-005] Authentication Protection for Routes
**As a** System
**I want** all routes protected by authentication
**So that** only authorized users can access the application

#### Acceptance Criteria
- [ ] Given I am not authenticated, When I access any protected route, Then I am redirected to `/login`
- [ ] Given I am authenticated as a Customer, When I access Driver routes, Then I receive 403 Forbidden
- [ ] Given I am authenticated as a Driver, When I access Customer routes, Then I receive 403 Forbidden
- [ ] Given I am authenticated, When I access public assets, Then they load without additional authentication
- [ ] Given I am not authenticated, When I access `/login` or `/register`, Then pages load normally

#### Domain Constraints
- **User roles:** Role-based authorization after authentication
- **Map implications:** Map components require authenticated user
- **AI feature:** AI features require authenticated user context

#### Technical Notes
- `ApplicationController` includes `Authentication` concern
- `before_action :authenticate` on all controllers except sessions/registrations
- Role-based authorization in specific controllers (e.g., `authorize_driver`, `authorize_customer`)
- Public routes: `/login`, `/register`, `/auth/google_oauth2/callback`
- Inertia handles authentication redirects gracefully

#### Priority: Must
#### Story Points: 2

---

### [AUTH-006] Remember Me Functionality
**As a** user
**I want** the option to stay logged in
**So that** I don't need to re-authenticate frequently

#### Acceptance Criteria
- [ ] Given I am on the login page, When I check "Remember me", Then my session persists for 30 days
- [ ] Given I login without "Remember me", When I close my browser, Then I must re-authenticate
- [ ] Given I have an active "Remember me" session, When I return after 29 days, Then I am still logged in
- [ ] Given I have an active "Remember me" session, When I explicitly logout, Then the persistent session is revoked

#### Domain Constraints
- **User roles:** Both Customer and Driver
- **Map implications:** None
- **AI feature:** None

#### Technical Notes
- Session cookie expiry controlled by `remember_me` checkbox
- Signed cookies prevent tampering
- Session model includes `remember_token` for persistent sessions
- Regular sessions expire on browser close

#### Priority: Should
#### Story Points: 2

---

## 5. Non-Functional Requirements

### Security Requirements
- **Password Requirements:** Minimum 8 characters, bcrypt hashing with cost factor 12
- **Session Security:** HTTP-only, secure cookies in production; sessions bound to IP and user agent
- **CSRF Protection:** Rails built-in CSRF tokens on all forms
- **OAuth Security:** State parameter validation, PKCE for OAuth 2.0
- **Rate Limiting:** 5 login attempts per IP per minute (via Rack::Attack)

### Privacy Requirements
- **PII Handling:** User email encrypted at rest using Rails Active Record Encryption (deterministic for lookups)
- **Log Filtering:** Email, password, and OAuth tokens filtered from all logs via `config.filter_parameters`
- **Data Minimization:** Only request necessary OAuth scopes (email, profile)
- **Consent Tracking:** Record user consent for terms of service during registration
- **Session Data:** IP addresses hashed before storage, user agents truncated to browser/OS

### Performance Requirements
- **Login Response:** < 500ms for credential validation
- **OAuth Callback:** < 2 seconds including user creation
- **Session Lookup:** < 50ms for `Current.user` initialization
- **Password Hashing:** Use bcrypt work factor appropriate for 100ms computation

### Accessibility Requirements
- **Form Labels:** All inputs have associated labels
- **Error Messages:** Associated with form fields via ARIA attributes
- **Keyboard Navigation:** Full form completion via keyboard only
- **Screen Readers:** Login and registration flows tested with NVDA/JAWS

### Design System Compliance (Precision Logistikos)
- **No Borders Rule:** Form sections use surface hierarchy, not lines
- **Typography:** Manrope for "Sign In" heading, Inter for form labels
- **Colors:** Primary gradient (#000e24 → #00234b) for submit button
- **Glassmorphism:** Optional for login page header overlay
- **Touch Targets:** Minimum 44x44dp for all interactive elements
- **Input Height:** 56px for easy mobile interaction

---

## 6. Privacy & Data Protection Considerations

### Data Collection
- **Minimal Collection:** Email, name, role for basic account; provider + UID for OAuth
- **Optional Fields:** Phone number (for Drivers), profile photo
- **Sensitive Data:** Passwords never logged, OAuth tokens never stored raw

### Data Storage
- **Encryption at Rest:** User email encrypted via `encrypts :email, deterministic: true`
- **Password Storage:** bcrypt hashed, never reversible
- **Session Storage:** Database-backed sessions with encrypted cookies

### Data Retention
- **Active Sessions:** Expire after 30 days of inactivity
- **Inactive Accounts:** Anonymized after 2 years of inactivity
- **Session History:** Purged after 90 days

### User Rights (GDPR/LGPD Compliance)
- **Right to Access:** Users can request all stored personal data
- **Right to Rectification:** Users can update email, name via profile
- **Right to Erasure:** Account deletion anonymizes user data
- **Consent Management:** Explicit consent for terms recorded during registration

### Audit Trail
- **Login Events:** Track successful/failed login attempts with timestamp and IP (hashed)
- **Session Creation:** Record device fingerprint for security monitoring
- **Role Changes:** Immutable after registration (audit log for any admin overrides)

---

## 7. Technical Constraints

### Rails 8 Authentication Requirements
- Must use `bin/rails generate authentication` as the foundation
- No Devise gem - use Rails built-in authentication
- Session-based authentication (no JWT tokens)
- `Current.user` singleton pattern for accessing authenticated user

### Integration Requirements
- OmniAuth 2.x with `omniauth-google-oauth2` gem
- CSRF protection via `omniauth-rails_csrf_protection`
- Inertia.js for SPA-like page transitions
- React components receive user props from Rails controllers

### Environment Configuration
- Development: `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` optional (test mode)
- Production: OAuth credentials required in Rails encrypted credentials
- Test: Uses OmniAuth test mode with mock auth hash

---

## 8. Out of Scope

- Password reset functionality (can be added post-MVP)
- Two-factor authentication (2FA)
- Email verification/confirmation
- Social logins beyond Google (Facebook, GitHub, etc.)
- Admin role and admin authentication
- API token authentication for mobile apps
- Session management UI (view all sessions, revoke specific sessions)
- Login history/audit log UI for users
- Biometric authentication
- SSO/SAML integration

---

## 9. Timeline & Milestones

### Day 1-2 (Initial Setup)
- [ ] Run Rails 8 authentication generator
- [ ] Configure OmniAuth Google OAuth2
- [ ] Create base Inertia pages (Login, Register)

### Day 3-4 (Core Implementation)
- [ ] Implement email/password registration and login
- [ ] Add role selection during registration
- [ ] Implement Google OAuth callback handling

### Day 5 (Integration & Protection)
- [ ] Add authentication protection to all routes
- [ ] Implement role-based authorization
- [ ] Configure session management and logout

### Day 6 (Privacy & Polish)
- [ ] Add PII encryption for user emails
- [ ] Implement consent tracking
- [ ] Apply Precision Logistikos design system
- [ ] Test mobile responsiveness

### Day 7 (Testing & Documentation)
- [ ] Write RSpec tests for all authentication flows
- [ ] Security testing (CSRF, session fixation)
- [ ] Update README with environment variables
- [ ] Final review and bug fixes

---

## 10. Open Questions

1. **Driver Verification:** Should drivers require additional verification (license, insurance) during registration, or is this deferred to a separate profile completion step?

2. **Email Verification:** Should we require email confirmation for email/password signups in the MVP, or allow immediate access?

3. **Role Switching:** Can users have both Customer and Driver roles (switching context), or is it one role per account?

4. **Guest Checkout:** Should customers be able to create orders without registration (guest mode), or is authentication always required?

5. **Password Complexity:** Beyond 8-character minimum, should we enforce complexity rules (uppercase, numbers, symbols)?

6. **Session Concurrency:** Should we limit users to one active session (single device), or allow multiple concurrent sessions?

7. **OAuth Scope:** Should we request additional Google scopes (calendar, maps) for future features, or minimize to email/profile only?

8. **Terms Acceptance:** Should terms of service acceptance be a checkbox during registration, or a separate screen after OAuth?

---

## 11. Dependencies

### Upstream Dependencies
- **003 (Database Schema):** User model and migrations must exist before authentication can be added

### Downstream Dependencies
- **005 (Order Creation):** Requires authenticated Customer user
- **006 (Driver Order Feed):** Requires authenticated Driver user
- **007 (Real-time Tracking):** Requires authenticated user context
- **011 (Notifications):** Requires user sessions for delivery

---

## 12. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Google OAuth downtime | Fallback to email/password; clear error messaging |
| Session hijacking | Bind sessions to IP + user agent; use secure, httponly cookies |
| Password brute force | Implement rate limiting via Rack::Attack |
| User enumeration | Generic error messages; same response time for invalid email vs password |
| OAuth account takeover | Verify email match between OAuth and existing account |
| PII exposure | Encrypt emails; filter all auth params from logs |
| CSRF attacks | Rails built-in CSRF protection; OmniAuth CSRF gem |
| Insecure passwords | Enforce minimum length; consider haveibeenpwned API in future |

---

## 13. Acceptance Test Scenarios

### Scenario 1: New Customer Registration
1. Navigate to `/register`
2. Select "Customer" role
3. Enter email, password, name
4. Submit form
5. Verify redirect to `/customer/dashboard`
6. Verify `Current.user.role == 'customer'`

### Scenario 2: Driver Google OAuth First Login
1. Navigate to `/login`
2. Click "Sign in with Google"
3. Authorize on Google
4. Redirect to role selection
5. Choose "Driver"
6. Verify redirect to `/driver/orders`
7. Verify user created with Google UID

### Scenario 3: Failed Login Attempt
1. Navigate to `/login`
2. Enter invalid credentials
3. Submit form
4. Verify error message displayed
5. Verify no session created
6. Verify no redirect occurs

### Scenario 4: Protected Route Access
1. Clear all cookies
2. Navigate to `/customer/orders/new`
3. Verify redirect to `/login`
4. Login as customer
5. Verify redirect back to `/customer/orders/new`

### Scenario 5: Logout Flow
1. Login as any user
2. Click "Logout" in navigation
3. Verify redirect to `/login`
4. Try accessing protected route
5. Verify redirect to `/login`
6. Verify session record deleted from database

---

## 14. Metrics & Monitoring

### Key Metrics to Track
- **Registration Conversion:** % of users who complete registration after starting
- **OAuth vs Email Split:** Ratio of Google OAuth to email/password signups
- **Login Success Rate:** Successful logins / total login attempts
- **Session Duration:** Average time between login and logout
- **Role Distribution:** % of Customer vs Driver registrations

### Error Monitoring
- Track OAuth callback failures
- Monitor bcrypt performance (password hashing time)
- Alert on unusual login patterns (geographic anomalies)
- Track PII encryption/decryption errors

### Security Monitoring
- Failed login attempts by IP
- Session hijacking indicators (IP/UA changes mid-session)
- Unusual role-switching attempts
- OAuth state parameter mismatches

---

*End of Specification*