# frozen_string_literal: true

module Orders
  class Creator
    attr_reader :user, :params, :order

    def initialize(user:, params:)
      @user = user
      @params = params
      @order = nil
    end

    def call
      return error_result("Payment method required") unless valid_payment_method?
      return error_result("User must be a customer") unless user.customer?

      ActiveRecord::Base.transaction do
        create_order
        generate_tracking_code
      end

      success_result
    rescue ActiveRecord::RecordInvalid => e
      error_result(e.record.errors)
    rescue ArgumentError => e
      # Handle enum validation errors (e.g., invalid size value)
      error_result(e.message)
    end

    private

    def valid_payment_method?
      # Check for default, active (non-expired) payment method
      user.payment_methods.default.active.exists?
    end

    def create_order
      items_params = params[:order_items_attributes] || []

      @order = user.delivery_orders.build(
        status: :processing,
        pickup_address: params[:pickup_address],
        dropoff_address: params[:dropoff_address],
        delivery_type: params[:delivery_type] || :immediate,
        scheduled_at: params[:scheduled_at],
        description: params[:description],
        suggested_price_cents: params[:suggested_price_cents]
      )

      # Build items in memory before saving
      items_params.each do |item_params|
        @order.order_items.build(
          name: item_params[:name],
          quantity: item_params[:quantity],
          size: item_params[:size]
        )
      end

      # Save order with items (validations will run)
      @order.save!
    end

    def generate_tracking_code
      # Generate unique tracking code with retry logic
      max_attempts = 10
      attempts = 0

      loop do
        code = "DEL-#{SecureRandom.alphanumeric(6).upcase}"

        begin
          @order.update!(tracking_code: code)
          break
        rescue ActiveRecord::RecordNotUnique
          attempts += 1
          raise "Failed to generate unique tracking code" if attempts >= max_attempts
        end
      end
    end

    def success_result
      Result.new(success: true, order: @order)
    end

    def error_result(errors)
      Result.new(success: false, errors: errors)
    end

    # Result object to encapsulate service response
    class Result
      attr_reader :order, :errors

      def initialize(success:, order: nil, errors: nil)
        @success = success
        @order = order
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !@success
      end
    end
  end
end
