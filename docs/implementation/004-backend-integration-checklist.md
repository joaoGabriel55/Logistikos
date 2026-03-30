# Backend Integration Checklist for Auth Frontend

This checklist ensures the Rails backend properly integrates with the authentication frontend pages.

## Prerequisites

- [ ] Rails 8 authentication generator has been run: `bin/rails generate authentication`
- [ ] User model exists with `role` field (enum: 'customer', 'driver')
- [ ] Session model exists
- [ ] OmniAuth gems installed (`omniauth-google-oauth2`, `omniauth-rails_csrf_protection`)

## Controllers to Implement

### SessionsController

```ruby
class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:new, :create]

  def new
    # Render Login page
    render inertia: 'Auth/Login', props: {
      googleOAuthUrl: google_oauth_enabled? ? '/auth/google_oauth2' : nil
    }
  end

  def create
    # Authenticate user
    # Create session
    # Redirect based on role
  end

  def destroy
    # Destroy session
    # Redirect to login
  end

  private

  def google_oauth_enabled?
    ENV['GOOGLE_OAUTH_CLIENT_ID'].present?
  end
end
```

### RegistrationsController

```ruby
class RegistrationsController < ApplicationController
  skip_before_action :authenticate, only: [:new, :create]

  def new
    # Render Register page
    render inertia: 'Auth/Register', props: {
      googleOAuthUrl: google_oauth_enabled? ? '/auth/google_oauth2' : nil
    }
  end

  def create
    # Create user with role
    # Create session
    # Redirect based on role
  end

  private

  def google_oauth_enabled?
    ENV['GOOGLE_OAUTH_CLIENT_ID'].present?
  end
end
```

### Auth::OmniauthCallbacksController

```ruby
class Auth::OmniauthCallbacksController < ApplicationController
  skip_before_action :authenticate

  def google_oauth2
    # Find or create user from auth hash
    # Create session
    # Handle first-time users (role selection)
    # Redirect based on role
  end
end
```

## Routes to Add

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Authentication routes
  get '/login', to: 'sessions#new', as: :login
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout

  get '/register', to: 'registrations#new', as: :register
  post '/register', to: 'registrations#create'

  # OmniAuth callback
  get '/auth/:provider/callback', to: 'auth/omniauth_callbacks#google_oauth2'
  get '/auth/failure', to: 'auth/omniauth_callbacks#failure'
end
```

## User Model Updates

### Required Fields
- [ ] `email` (string, encrypted, unique)
- [ ] `password_digest` (string)
- [ ] `name` (string)
- [ ] `role` (enum: 'customer', 'driver')
- [ ] `provider` (string, nullable) - for OAuth ('google_oauth2')
- [ ] `uid` (string, nullable) - for OAuth (Google user ID)

### Validations
```ruby
class User < ApplicationRecord
  has_secure_password

  encrypts :email, deterministic: true

  enum role: { customer: 'customer', driver: 'driver' }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :password, length: { minimum: 8 }, if: :password_digest_changed?

  # OAuth
  def self.from_omniauth(auth_hash)
    # Find or create user by provider + uid
  end
end
```

## Session Model Updates

```ruby
class Session < ApplicationRecord
  belongs_to :user

  validates :ip_address, presence: true
  validates :user_agent, presence: true

  before_create :set_security_fields

  private

  def set_security_fields
    # Hash IP address
    # Truncate user agent
  end
end
```

## Environment Variables

Add to `.env` (development):
```bash
GOOGLE_OAUTH_CLIENT_ID=your_client_id_here
GOOGLE_OAUTH_CLIENT_SECRET=your_client_secret_here
```

Add to Rails encrypted credentials (production):
```bash
bin/rails credentials:edit
```

```yaml
google:
  oauth_client_id: xxx
  oauth_client_secret: xxx
```

## OmniAuth Configuration

Create `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :oauth_client_id) || ENV['GOOGLE_OAUTH_CLIENT_ID'],
    Rails.application.credentials.dig(:google, :oauth_client_secret) || ENV['GOOGLE_OAUTH_CLIENT_SECRET'],
    {
      scope: 'email,profile',
      prompt: 'select_account',
      image_aspect_ratio: 'square',
      image_size: 50
    }
end

# CSRF protection
OmniAuth.config.allowed_request_methods = [:post, :get]
```

## Form Parameter Handling

### Login Form
Expected params:
```ruby
params.permit(:email, :password, :remember)
```

### Registration Form
Expected params:
```ruby
params.permit(:name, :email, :password, :password_confirmation, :role)
```

## Redirect Logic

After successful authentication:

```ruby
def redirect_after_login
  case current_user.role
  when 'customer'
    redirect_to customer_orders_path
  when 'driver'
    redirect_to driver_orders_path
  else
    redirect_to root_path
  end
end
```

## Error Handling

### Validation Errors
Return as Inertia errors:

```ruby
if @user.save
  # Success
else
  render inertia: 'Auth/Register', props: {
    errors: @user.errors.messages
  }
end
```

### Authentication Errors
```ruby
render inertia: 'Auth/Login', props: {
  errors: { email: ['Invalid email or password'] }
}
```

## Testing Checklist

### RSpec Tests

- [ ] `spec/requests/sessions_spec.rb`
  - GET /login renders Login page
  - POST /login with valid credentials creates session
  - POST /login with invalid credentials shows error
  - DELETE /logout destroys session

- [ ] `spec/requests/registrations_spec.rb`
  - GET /register renders Register page
  - POST /register with valid data creates user
  - POST /register with invalid email shows error
  - POST /register without role shows error
  - POST /register with weak password shows error

- [ ] `spec/requests/auth/omniauth_callbacks_spec.rb`
  - GET /auth/google_oauth2/callback with valid auth creates user
  - GET /auth/google_oauth2/callback with existing user logs in

### System Tests

- [ ] User can log in with email/password
- [ ] User can register as Customer
- [ ] User can register as Driver
- [ ] User can use "Remember me"
- [ ] User can log out
- [ ] Error messages display correctly
- [ ] Validation errors show inline

## Security Checklist

- [ ] CSRF tokens included in all forms (Inertia handles this)
- [ ] Passwords never logged or exposed
- [ ] Email encrypted at rest
- [ ] Session cookies are HTTP-only and secure in production
- [ ] Rate limiting on login endpoint (Rack::Attack)
- [ ] OAuth state parameter validated
- [ ] User enumeration prevented (generic error messages)

## Accessibility Checklist

- [ ] All form fields have labels
- [ ] Error messages associated with fields
- [ ] Keyboard navigation works
- [ ] Focus management on errors
- [ ] Screen reader tested

## Performance Checklist

- [ ] Login response < 500ms
- [ ] OAuth callback < 2 seconds
- [ ] Session lookup < 50ms
- [ ] bcrypt work factor appropriate (12)

## Documentation

- [ ] Update README with OAuth setup instructions
- [ ] Document environment variables
- [ ] Add authentication flow diagram
- [ ] Document role-based routing

## Deployment Checklist

- [ ] Environment variables set in production
- [ ] OAuth credentials in Rails credentials
- [ ] OAuth redirect URI configured in Google Console
- [ ] HTTPS enforced in production
- [ ] Session cookie domain configured

## Common Issues & Solutions

### "Sign in with Google" button not showing
- Check that `GOOGLE_OAUTH_CLIENT_ID` is set
- Ensure `googleOAuthUrl` prop is passed to Inertia page

### OAuth callback fails
- Verify redirect URI matches Google Console configuration
- Check OmniAuth initializer is configured
- Ensure CSRF protection is properly configured

### Validation errors not displaying
- Check controller is returning errors hash
- Verify Inertia error prop structure
- Console.log errors in frontend to debug

### Remember me not working
- Check session cookie expiry logic
- Verify remember token in session model
- Test cookie persistence across browser restarts

## Next Steps

After completing this checklist:

1. Test all flows manually
2. Run RSpec test suite
3. Test on mobile devices
4. Security review (Brakeman)
5. Load testing for login endpoint
6. Deploy to staging
7. QA review
8. Deploy to production

---

**Related Documents:**
- `/docs/specs/004-authentication-spec.md`
- `/docs/implementation/004-auth-frontend-implementation.md`
- `/frontend/pages/Auth/README.md`
