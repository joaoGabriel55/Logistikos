/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './frontend/**/*.{js,ts,jsx,tsx}',
    './app/views/**/*.html.erb'
  ],
  theme: {
    extend: {
      colors: {
        // Precision Logistikos Design System
        primary: '#000e24',
        'primary-container': '#00234b',
        secondary: '#a33800',
        'secondary-fixed': '#ffdbce',
        surface: '#f8f9fb',
        'surface-container-low': '#f3f4f6',
        'surface-container-lowest': '#ffffff',
        'surface-container-high': '#e7e8ea',
        'surface-container-highest': '#e1e2e4',
        'surface-dim': '#d9dadc',
        'surface-bright': '#f8f9fb',
        'surface-tint': '#455f8a',
        'on-surface': '#191c1e',
        'on-surface-variant': '#43474e',
        'on-primary-fixed-variant': '#2c4771',
        'tertiary-container': '#001f5a',
        'on-tertiary-container': '#5384ff',
        'outline-variant': '#c4c6d0'
      },
      fontFamily: {
        display: ['Manrope', 'sans-serif'],
        body: ['Inter', 'sans-serif']
      },
      fontSize: {
        'display-lg': '3.5rem',
        'display-md': '2.75rem',
        'display-sm': '2.25rem',
        'headline-lg': '2rem',
        'headline-md': '1.75rem',
        'headline-sm': '1.5rem',
        'title-lg': '1.375rem',
        'title-md': '1.125rem',
        'title-sm': '0.875rem',
        'body-lg': '1rem',
        'body-md': '0.875rem',
        'body-sm': '0.75rem',
        'label-lg': '0.875rem',
        'label-md': '0.75rem',
        'label-sm': '0.6875rem'
      },
      borderRadius: {
        md: '0.75rem'
      },
      spacing: {
        '5': '1.1rem',
        '8': '1.75rem'
      },
      backdropBlur: {
        glass: '20px'
      },
      boxShadow: {
        'ambient': '0 8px 24px rgba(25, 28, 30, 0.06)'
      }
    }
  },
  plugins: []
}
