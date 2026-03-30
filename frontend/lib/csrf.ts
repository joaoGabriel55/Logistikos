/**
 * CSRF Token Utility
 *
 * Rails sets the CSRF token in:
 * 1. Meta tag: <meta name="csrf-token" content="...">
 * 2. Cookie: XSRF-TOKEN (for Inertia.js XHR requests)
 *
 * This utility retrieves the token from the meta tag for use in
 * plain HTML forms (like OAuth redirects).
 */

/**
 * Get the CSRF token from the meta tag
 * @returns The CSRF token string, or empty string if not found
 */
export function getCsrfToken(): string {
  const metaTag = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')
  return metaTag?.content || ''
}

/**
 * Get the CSRF token from the XSRF-TOKEN cookie
 * This is used by Inertia.js for XHR requests
 * @returns The CSRF token from cookie, or empty string if not found
 */
export function getCsrfTokenFromCookie(): string {
  const match = document.cookie.match(/XSRF-TOKEN=([^;]+)/)
  return match ? decodeURIComponent(match[1]) : ''
}
