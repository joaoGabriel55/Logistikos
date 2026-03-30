class User < ApplicationRecord
  include Anonymizable
  include DataExportable
  include HasConsent

  has_secure_password

  # Associations
  has_one :driver_profile, dependent: :destroy
  has_many :delivery_orders, foreign_key: :created_by, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :consents, dependent: :destroy

  # As a driver
  has_many :assignments, foreign_key: :driver_id, dependent: :restrict_with_error
  has_many :driver_earnings, foreign_key: :driver_id, dependent: :restrict_with_error

  # As a customer
  has_many :payments, foreign_key: :customer_id, dependent: :restrict_with_error

  # Enums
  enum :role, { customer: 0, driver: 1 }, prefix: true

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  # OAuth validations
  validates :uid, uniqueness: { scope: :provider }, if: -> { provider.present? }

  # PII encryption using Rails 8 built-in encryption
  encrypts :name
  encrypts :email, deterministic: true, downcase: true

  # Filter sensitive attributes from logs
  self.filter_attributes = %i[name email password_digest]

  # Scopes
  scope :customers, -> { where(role: :customer) }
  scope :drivers, -> { where(role: :driver) }

  # Methods
  def customer?
    role_customer?
  end

  def driver?
    role_driver?
  end
end
