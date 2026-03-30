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
        'display-md': '2.75rem',
        'title-md': '1.125rem',
        'label-md': '0.75rem'
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
      }
    }
  },
  plugins: []
}
