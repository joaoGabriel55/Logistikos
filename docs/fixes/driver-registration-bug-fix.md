# Driver Registration Bug Fix

**Date:** 2026-03-30
**Issue:** Email/password users could not register as drivers despite UI showing the option

## Problem Summary

The registration flow had an inconsistency between frontend and backend:

- **Frontend** (`Register.tsx`): Showed role selector with "Send Items" (customer) and "Deliver Items" (driver) options
- **Backend** (`RegistrationsController`): Hardcoded role to `:customer`, ignoring user selection
- **OAuth Flow**: Worked correctly via separate `RoleSelectionController`

This caused users selecting "Deliver Items" to be silently converted to customers, preventing access to driver-specific pages.

## Affected Users

- **User #25** ("Deliver Guy"): Was incorrectly assigned customer role
  - ✅ Manually corrected to driver role
  - ✅ Driver profile created with defaults

## Changes Made

### 1. Updated `RegistrationsController` (app/controllers/registrations_controller.rb)

**Before:**
```ruby
def create
  user = User.new(registration_params.merge(role: :customer))
  # ...
end
```

**After:**
```ruby
def create
  # Validate role parameter
  unless ["customer", "driver"].include?(params[:role])
    # Return error
  end

  user = User.new(registration_params.merge(role: params[:role]))

  # Create driver_profile for driver users
  if user.driver?
    user.create_driver_profile!(
      vehicle_type: :car,
      is_available: false,
      radius_preference_km: 10.0
    )
  end
  # ...
end
```

### 2. Updated Specs (spec/controllers/registrations_controller_spec.rb)

- Removed obsolete "privilege escalation protection" tests
- Added tests for driver role registration
- Added tests for role validation
- Added tests for driver_profile creation
- Fixed session key reference (`:session_id` → `:user_session_id`)

### 3. Fixed Related Test (spec/controllers/auth/role_selection_controller_spec.rb)

- Fixed session key reference to match Authentication concern

## Verification

✅ All registration controller specs pass (15 examples, 0 failures)
✅ All role selection controller specs pass (7 examples, 0 failures)
✅ Manual test confirms driver registration works correctly
✅ User #25 can now access `/driver_profile`

## Security Notes

- Role parameter is validated against whitelist `["customer", "driver"]`
- Invalid roles return error without creating user
- Missing role parameter returns error
- Driver profile creation wrapped in transaction for data integrity

## Impact

- Email/password users can now properly register as drivers
- Frontend role selector now functions as intended
- Parity achieved between OAuth and email/password registration flows
