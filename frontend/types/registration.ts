import { IconType } from 'react-icons'
import { UserRole, VehicleType } from './models'

export interface RegistrationFormData {
  name: string
  email: string
  password: string
  password_confirmation: string
  role: UserRole | ''
  vehicle_type: VehicleType
  radius_preference_km: string
}

export interface VehicleOptionData {
  value: VehicleType
  label: string
  icon: IconType
  description: string
}

export interface RadiusOptionData {
  value: string
  label: string
  description: string
}

export type RegistrationStep = 1 | 2
