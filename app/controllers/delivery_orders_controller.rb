# frozen_string_literal: true

class DeliveryOrdersController < ApplicationController
  before_action :authenticate
  before_action :require_customer

  def new
    render inertia: "Customer/OrderCreate", props: {
      has_payment_method: has_valid_payment_method?,
      user: user_data
    }
  end

  def create
    result = Orders::Creator.new(user: Current.user, params: order_params).call

    if result.success?
      render json: DeliveryOrderSerializer.new(result.order).as_json, status: :created
    else
      render json: { errors: format_errors(result.errors) }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:delivery_order).permit(
      :pickup_address,
      :dropoff_address,
      :delivery_type,
      :scheduled_at,
      :description,
      :suggested_price_cents,
      order_items_attributes: [ :name, :quantity, :size ]
    )
  end

  def has_valid_payment_method?
    Current.user.payment_methods.default.active.exists?
  end

  def user_data
    {
      id: Current.user.id,
      name: Current.user.name,
      email: Current.user.email,
      role: Current.user.role
    }
  end

  def format_errors(errors)
    if errors.is_a?(String)
      { base: [ errors ] }
    elsif errors.is_a?(ActiveModel::Errors)
      errors.to_hash
    else
      errors
    end
  end
end
