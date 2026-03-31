# frozen_string_literal: true

module Driver
  class OrdersController < ApplicationController
    before_action :authenticate
    before_action :require_driver

    def index
      render inertia: "Driver/Orders", props: {
        orders: []
      }
    end
  end
end
