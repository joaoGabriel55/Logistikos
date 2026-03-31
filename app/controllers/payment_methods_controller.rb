# frozen_string_literal: true

# PaymentMethodsController
# Manages customer payment methods (cards, bank accounts)
# Full implementation in ticket 030 - this is a stub for MVP
class PaymentMethodsController < ApplicationController
  before_action :authenticate
  before_action :require_customer

  # GET /payment_methods
  def index
    @payment_methods = Current.user.payment_methods.order(is_default: :desc, created_at: :desc)
    render inertia: "Customer/PaymentMethods/Index", props: {
      payment_methods: @payment_methods.map { |pm| serialize_payment_method(pm) }
    }
  end

  # GET /payment_methods/new
  def new
    render inertia: "Customer/PaymentMethods/New"
  end

  # POST /payment_methods
  def create
    # TODO: Implement in ticket 030
    # For now, just redirect back with a notice
    redirect_to payment_methods_path, notice: "Payment method management is coming soon (Ticket 030)"
  end

  # DELETE /payment_methods/:id
  def destroy
    payment_method = Current.user.payment_methods.find(params[:id])
    payment_method.destroy
    redirect_to payment_methods_path, notice: "Payment method removed successfully"
  end

  # PATCH /payment_methods/:id/set_default
  def set_default
    payment_method = Current.user.payment_methods.find(params[:id])

    ActiveRecord::Base.transaction do
      Current.user.payment_methods.update_all(is_default: false)
      payment_method.update!(is_default: true)
    end

    redirect_to payment_methods_path, notice: "Default payment method updated"
  end

  private

  def serialize_payment_method(payment_method)
    {
      id: payment_method.id,
      card_brand: payment_method.card_brand || "Unknown",
      last_four: payment_method.card_last_four || "0000",
      expires_at: payment_method.expires_at&.iso8601,
      is_default: payment_method.is_default,
      is_expired: payment_method.expired?,
      gateway_provider: payment_method.gateway_provider,
      created_at: payment_method.created_at.iso8601
    }
  end
end
