class OrderItem < ApplicationRecord
  belongs_to :delivery_order

  # Enums
  enum :size, { small: 0, medium: 1, large: 2, bulk: 3 }, prefix: true

  # Validations
  validates :delivery_order, presence: true
  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :quantity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 999, only_integer: true }
  validates :size, presence: true
end
