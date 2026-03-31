# frozen_string_literal: true

module Customer
  class DashboardController < ApplicationController
    before_action :authenticate
    before_action :require_customer

    def index
      render inertia: "Customer/Dashboard", props: {
        stats: {
          total_orders: 0,
          active_orders: 0,
          completed_orders: 0
        }
      }
    end
  end
end
