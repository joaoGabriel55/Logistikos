# Google OAuth Update - ConnectedService Implementation

## Summary

Updated Google OAuth authentication to use the Avo blog post pattern with a separate `ConnectedService` model for managing OAuth connections. This provides better security and flexibility compared to storing provider/uid directly on the User model.

## Changes Made

### 1. Database Changes

**Created `connected_services` table:**
- Migration: `20260330195551_create_connected_services.rb`
- Columns: `user_id`, `provider`, `uid`, `timestamps`
- Indexes:
  - Unique index on `[provider, uid]` - prevents duplicate OAuth connections
  - Index on `user_id` - for efficient lookups

**Removed OAuth fields from users table:**
- Migration: `20260330195715_remove_o_auth_fields_from_users.rb`
- Removed columns: `provider`, `uid`

### 2. Model Changes

**Created `ConnectedService` model** (`app/models/connected_service.rb`):
- `belongs_to :user`
- Validates presence of `provider` and `uid`
- Validates uniqueness of `uid` scoped to `provider`

**Updated `User` model** (`app/models/user.rb`):
- Added `has_many :connected_services, dependent: :destroy`
- Removed `from_omniauth` class method (logic moved to controller)
- Removed OAuth validations for `uid` uniqueness

### 3. Controller Changes

**Updated `Auth::OmniauthCallbacksController`** (`app/controllers/auth/omniauth_callbacks_controller.rb`):
- Implemented `resolve_user_from_auth` private method with priority-based user resolution:
  1. **Priority 1:** Currently authenticated user (for connecting additional providers)
  2. **Priority 2:** Existing `ConnectedService` record (returning user)
  3. **Priority 3:** User with matching email (linking OAuth to existing account)
  4. **Priority 4:** Return nil for new user creation
- Maintains existing role selection flow for new users

**Updated `Auth::RoleSelectionController`** (`app/controllers/auth/role_selection_controller.rb`):
- User creation now happens in a transaction
- Creates `ConnectedService` record after user is successfully created
- User model no longer includes `provider`/`uid` fields

### 4. Configuration Changes

**Updated OmniAuth initializer** (`config/initializers/omniauth.rb`):
- Changed to prefer Rails credentials over ENV vars
- Fallback to ENV vars for backwards compatibility:
  ```ruby
  Rails.application.credentials.dig(:google, :client_id) || ENV.fetch("GOOGLE_OAUTH_CLIENT_ID", nil)
  ```

### 5. Test Updates

**Created ConnectedService specs:**
- Model validations and associations
- Database constraints (unique index enforcement)
- Factory with traits for different providers

**Updated controller specs:**
- Added test for linking OAuth to existing email-based accounts
- Updated to use `connected_services` instead of `provider`/`uid`
- All existing functionality maintained

**Updated User model specs:**
- Removed `from_omniauth` tests (logic moved to controller)
- Added test for multiple OAuth providers per user
- Updated associations to include `connected_services`
- Removed OAuth-specific validation tests

**Updated user factory:**
- Changed `:with_oauth` trait to use `after(:create)` callback
- Creates associated `ConnectedService` instead of setting `provider`/`uid`

## Benefits

1. **Better Security:**
   - Separates OAuth connections from user identity
   - Prevents email-based account takeovers
   - Each provider/uid combination globally unique

2. **Flexibility:**
   - Users can connect multiple OAuth providers (Google, GitHub, etc.)
   - Existing email-based accounts can add OAuth connections
   - OAuth users can add password authentication later

3. **Cleaner Architecture:**
   - Single Responsibility Principle: User model for user data, ConnectedService for OAuth
   - Easier to add new OAuth providers
   - Better separation of concerns

## Testing

All tests pass:
- 78 examples, 0 failures
- Coverage includes:
  - New user OAuth registration with role selection
  - Existing user login via OAuth
  - Linking OAuth to existing email account
  - Multiple OAuth providers per user
  - Database constraint enforcement

## Migration Path

For existing deployments with OAuth users:
1. Run migrations to create `connected_services` table
2. Data migration script would be needed to copy existing `provider`/`uid` to `connected_services`
3. Run migration to remove `provider`/`uid` from users table

## References

- [Avo HQ Blog Post: Social Login Auth Generator](https://avohq.io/blog/social-login-auth-generator)
- Implementation follows Rails 8 built-in authentication patterns
- Uses `omniauth-rails_csrf-protection` for security
