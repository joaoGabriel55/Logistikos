import { useCallback } from 'react'
import { getCsrfToken } from '@/lib/csrf'

/**
 * Custom hook for handling OAuth redirects with CSRF protection
 *
 * OAuth flows require full-page POST redirects to external providers (like Google),
 * which cannot be handled by Inertia.js XHR requests. This hook programmatically
 * creates and submits a form with the proper CSRF token.
 *
 * @param url - The OAuth provider URL (e.g., '/auth/google_oauth2')
 * @returns A click handler function that submits the OAuth form
 *
 * @example
 * ```tsx
 * const handleGoogleLogin = useOAuthRedirect('/auth/google_oauth2')
 *
 * <button onClick={handleGoogleLogin}>
 *   Continue with Google
 * </button>
 * ```
 */
export function useOAuthRedirect(url: string) {
  return useCallback(() => {
    // Create a temporary form element
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = url

    // Add CSRF token as hidden input
    const csrfInput = document.createElement('input')
    csrfInput.type = 'hidden'
    csrfInput.name = 'authenticity_token'
    csrfInput.value = getCsrfToken()
    form.appendChild(csrfInput)

    // Append to body, submit, and clean up
    document.body.appendChild(form)
    form.submit()
    // Note: Form is not removed because page will redirect before cleanup
  }, [url])
}
