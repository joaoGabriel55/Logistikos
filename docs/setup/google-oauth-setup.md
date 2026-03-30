# Google OAuth Setup Guide

## Overview

This guide walks through setting up Google OAuth authentication for Logistikos.

## Prerequisites

- Google Cloud Console account
- Project created in Google Cloud Console

## Step 1: Create OAuth 2.0 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Select your project (or create a new one)
3. Click **"Create Credentials"** → **"OAuth client ID"**
4. Configure the OAuth consent screen if prompted:
   - User Type: **External** (for testing)
   - App name: **Logistikos**
   - User support email: Your email
   - Developer contact: Your email
   - Save and continue

5. Create OAuth Client ID:
   - Application type: **Web application**
   - Name: **Logistikos (Development)**

6. **Add Authorized redirect URIs** (CRITICAL):
   ```
   http://localhost:3000/auth/google_oauth2/callback
   ```

   For production, also add:
   ```
   https://yourdomain.com/auth/google_oauth2/callback
   ```

7. Click **"Create"**
8. Copy the **Client ID** and **Client Secret**

## Step 2: Configure Credentials in Rails

### Option A: Using .env file (Development - Recommended)

The `.env` file is already configured. Update it with your credentials:

```bash
# .env
GOOGLE_OAUTH_CLIENT_ID=your_actual_client_id.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=GOCSPX-your_actual_client_secret
```

**Note:** `.env` is gitignored. Never commit real credentials!

### Option B: Using Rails Encrypted Credentials (Production)

```bash
# Edit credentials
EDITOR="code --wait" rails credentials:edit

# Add this content:
google:
  client_id: your_actual_client_id.apps.googleusercontent.com
  client_secret: GOCSPX-your_actual_client_secret
```

## Step 3: Restart the Server

After updating credentials:

```bash
# Stop the current server (Ctrl+C)
# Then restart
bin/dev
```

## Step 4: Test OAuth Flow

1. Visit http://localhost:3000/login
2. Click **"Continue with Google"**
3. You should be redirected to Google's consent screen
4. After authorizing, you'll be redirected back to select your role
5. Complete registration

## Common Issues

### Error: "Authorization Error - Missing required parameter: client_id"

**Cause:** Environment variables not loaded or incorrect

**Fix:**
1. Ensure `dotenv-rails` gem is installed (already done)
2. Verify `.env` file has correct credentials
3. Restart Rails server to load new ENV vars

### Error: "redirect_uri_mismatch"

**Cause:** The redirect URI in your request doesn't match what's configured in Google Cloud Console

**Fix:**
1. Go to Google Cloud Console → Credentials
2. Edit your OAuth 2.0 Client ID
3. Ensure this exact URL is in "Authorized redirect URIs":
   ```
   http://localhost:3000/auth/google_oauth2/callback
   ```
4. Save and try again (changes are instant)

### Error: "Access blocked: This app's request is invalid"

**Cause:** OAuth consent screen not properly configured

**Fix:**
1. Complete the OAuth consent screen configuration
2. Add your email to "Test users" if using External user type
3. Ensure all required fields are filled

## Security Notes

### Development
- ✅ `.env` file for local development
- ❌ Never commit `.env` to git
- ✅ Use `.env.example` for documentation

### Production
- ✅ Use Rails encrypted credentials
- ✅ Or use environment variables from your hosting platform
- ❌ Never expose client secrets in frontend code

## Testing OAuth (Development)

For automated tests, use OmniAuth test mode:

```ruby
# In test environment
ENV["OMNIAUTH_TEST_MODE"] = "true"

# Then in tests:
OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  provider: 'google_oauth2',
  uid: '123456',
  info: { email: 'test@example.com', name: 'Test User' }
})
```

## References

- [OmniAuth Google OAuth2 Strategy](https://github.com/zquestz/omniauth-google-oauth2)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Rails Encrypted Credentials Guide](https://guides.rubyonrails.org/security.html#custom-credentials)
