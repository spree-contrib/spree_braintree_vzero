module Spree
  module Api
    module V1
      class BraintreeClientTokenController < Spree::Api::BaseController
        skip_before_action :authenticate_user

        before_action :find_order, only: :create

        def create
          gateway = if params[:payment_method_id]
            Spree::Gateway::BraintreeVzeroBase.find(params[:payment_method_id])
          else
            Spree::Gateway::BraintreeVzeroBase.active.first
          end

          render json: {
            client_token: gateway.client_token(@order, @current_api_user),
            payment_method_id: gateway.id
          }
        end

        private

        # We're skipping permission check for order, because it is needed only to get a currency
        def find_order
          @order = Spree::Order.find_by(number: params[:order_number])
        end
      end
    end
  end
end
