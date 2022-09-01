module Spree
  module Api
    module V2
      class BraintreeClientTokenController < ::Spree::Api::V2::BaseController
        include Spree::Api::V2::Storefront::OrderConcern
        before_action :ensure_order

        def create
          gateway = if params[:payment_method_id]
            Spree::Gateway::BraintreeVzeroBase.find(params[:payment_method_id])
          else
            Spree::Gateway::BraintreeVzeroBase.active.first
          end

          render json: {
            client_token: gateway.client_token(spree_current_order, @current_api_user),
            payment_method_id: gateway.id
          }
        end

      end
    end
  end
end
