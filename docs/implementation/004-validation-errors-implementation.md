# Validation Errors Implementation

**Date:** 2026-03-30
**Branch:** 004/authentication
**Status:** ✅ Completed

## Overview

Implemented comprehensive validation error handling for authentication forms (login and registration) with proper Inertia.js integration and full RSpec test coverage.

## Changes Made

### 1. Controllers Updated

#### SessionsController (`app/controllers/sessions_controller.rb`)
- **Before:** Used `redirect_to` with flash alerts for validation errors
- **After:** Returns Inertia responses with field-level errors
- **Changes:**
  - Added blank field validation for email and password
  - Returns errors in Inertia-compatible format: `{ email: "message" }`
  - Maintains generic error message for invalid credentials (prevents user enumeration)

```ruby
# Example error response
render inertia: "Auth/Login", props: {
  googleOAuthUrl: "/auth/google_oauth2",
  errors: { email: "Invalid email or password" }
}
```

#### RegistrationsController (`app/controllers/registrations_controller.rb`)
- **Before:** Used `redirect_to` with concatenated error messages
- **After:** Returns Inertia responses with structured field-level errors
- **Changes:**
  - Formats ActiveRecord errors into Inertia format
  - Transforms `errors.messages` to `{ field => first_message }`
  - Properly renders validation errors for all fields

```ruby
# Example error transformation
formatted_errors = user.errors.messages.transform_values { |messages| messages.first }
```

### 2. Model Validations Enhanced

#### User Model (`app/models/user.rb`)
- **Added:** Password confirmation validation
- **Why:** `has_secure_password validations: false` disables default validations
- **New validation:** `validates :password, confirmation: true, if: -> { password.present? }`

**Existing validations:**
- `name`: presence
- `email`: presence, uniqueness, format (email)
- `role`: presence
- `password`: presence, minimum 8 characters (conditional)
- `password_confirmation`: must match password (NEW)

### 3. Frontend Updates

#### Login.tsx & Register.tsx
- **OAuth Button Change:** Changed from `<Link method="post">` to `router.post()`
- **Why:** More reliable CSRF token handling with OmniAuth
- **Added:** `handleGoogleLogin()` / `handleGoogleRegister()` functions using `router.post()`

**Error Display:**
- Frontend components already had error handling in place
- Errors display inline under each form field
- Format: `{errors.email && <p className="mt-2 text-sm text-secondary">{errors.email}</p>}`

### 4. Comprehensive Test Coverage

#### SessionsController Specs (`spec/controllers/sessions_controller_spec.rb`)
**New test cases:**
- ✅ Missing email returns validation error
- ✅ Missing password returns validation error
- ✅ Invalid credentials return generic error (security)
- ✅ Non-existent email returns generic error (security)
- ✅ All errors properly formatted in Inertia response

**Test approach:**
- Added `X-Inertia` headers to get JSON responses in tests
- Parse response body to verify error structure
- Verify no session created on validation failure

```ruby
# Example test pattern
request.headers["X-Inertia"] = "true"
request.headers["X-Inertia-Version"] = "1"
post :create, params: { email: "", password: "password123" }

inertia_data = JSON.parse(response.body)
expect(inertia_data["props"]["errors"]["email"]).to eq("Email can't be blank")
```

#### RegistrationsController Specs (`spec/controllers/registrations_controller_spec.rb`)
**New test cases:**
- ✅ Short password (< 8 chars) validation
- ✅ Missing role validation
- ✅ Invalid email format validation
- ✅ Missing email validation
- ✅ Missing name validation
- ✅ Missing password validation
- ✅ Mismatched password confirmation validation
- ✅ Duplicate email validation

**Test results:** All 26 authentication specs pass
**Coverage:** Login (13 specs) + Registration (13 specs)

## Validation Error Messages

### Login Form
| Field    | Condition           | Error Message                  |
|----------|---------------------|--------------------------------|
| email    | Blank               | "Email can't be blank"         |
| password | Blank               | "Password can't be blank"      |
| email    | Invalid credentials | "Invalid email or password"    |

### Registration Form
| Field                  | Condition      | Error Message                              |
|------------------------|----------------|--------------------------------------------|
| name                   | Blank          | "can't be blank"                           |
| email                  | Blank          | "can't be blank"                           |
| email                  | Invalid format | "is invalid"                               |
| email                  | Duplicate      | "has already been taken"                   |
| password               | Blank          | "can't be blank"                           |
| password               | Too short      | "is too short (minimum is 8 characters)"   |
| password_confirmation  | Mismatch       | "doesn't match Password"                   |
| role                   | Blank          | "can't be blank"                           |

## Security Considerations

1. **User Enumeration Prevention:** Login errors use generic "Invalid email or password" message
2. **CSRF Protection:** Maintained for all POST requests via Inertia's automatic CSRF handling
3. **PII Protection:** Email/name remain encrypted (Rails `encrypts` directive)
4. **Rate Limiting:** Not implemented yet (future consideration)

## Testing Validation Errors

### Manual Testing
1. Navigate to `/login` or `/register`
2. Submit empty form → See "can't be blank" errors
3. Submit invalid email → See "is invalid" error
4. Submit short password → See "is too short" error
5. Submit mismatched passwords → See "doesn't match" error

### Automated Testing
```bash
# Run all authentication specs
bundle exec rspec spec/controllers/sessions_controller_spec.rb spec/controllers/registrations_controller_spec.rb

# Run with documentation format
bundle exec rspec spec/controllers/ --format documentation
```

## Known Issues Fixed

1. ✅ OAuth CSRF token error - Fixed by using `router.post()` instead of `Link method="post"`
2. ✅ Password confirmation not validated - Fixed by adding explicit validation to User model
3. ✅ Redirects losing validation errors - Fixed by using Inertia render instead of redirects

## Next Steps

- [ ] Add client-side validation (optional, for better UX)
- [ ] Add rate limiting for authentication endpoints
- [ ] Add "Remember me" functionality for extended sessions
- [ ] Add "Forgot password" flow

## Files Modified

**Controllers:**
- `app/controllers/sessions_controller.rb`
- `app/controllers/registrations_controller.rb`

**Models:**
- `app/models/user.rb`

**Frontend:**
- `frontend/pages/Auth/Login.tsx`
- `frontend/pages/Auth/Register.tsx`

**Specs:**
- `spec/controllers/sessions_controller_spec.rb`
- `spec/controllers/registrations_controller_spec.rb`

**Routes:**
- `config/routes.rb` (OAuth routes clarified)

## References

- Inertia.js Validation Docs: https://inertiajs.com/validation
- Rails Validation Guide: https://guides.rubyonrails.org/active_record_validations.html
- has_secure_password Docs: https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html
