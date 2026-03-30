// Domain model type definitions
// These will be expanded as the application grows

export type UserRole = 'customer' | 'driver'

export interface User {
  id: number
  email: string
  name: string
  role: UserRole
  createdAt?: string
  updatedAt?: string
}

export interface DeliveryOrder {
  id: number
  customerId: number
  driverId?: number
  status: OrderStatus
  pickupAddress: string
  deliveryAddress: string
  estimatedPrice: number
  createdAt: string
  updatedAt: string
}

export type OrderStatus =
  | 'processing'
  | 'open'
  | 'accepted'
  | 'pickup_in_progress'
  | 'in_transit'
  | 'completed'
  | 'cancelled'
  | 'expired'
  | 'error'

export interface Driver {
  id: number
  userId: number
  licenseNumber: string
  vehicleType: string
  rating?: number
  totalDeliveries?: number
}

export interface OrderItem {
  id: number
  orderId: number
  description: string
  weight?: number
  quantity: number
  cargoType?: string
}
