import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    react()
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './frontend'),
      '@components': path.resolve(__dirname, './frontend/components'),
      '@pages': path.resolve(__dirname, './frontend/pages'),
      '@hooks': path.resolve(__dirname, './frontend/hooks'),
      '@types': path.resolve(__dirname, './frontend/types'),
      '@lib': path.resolve(__dirname, './frontend/lib'),
      '@layouts': path.resolve(__dirname, './frontend/layouts')
    }
  }
})
