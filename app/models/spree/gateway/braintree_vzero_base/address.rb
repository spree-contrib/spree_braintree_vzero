module Spree
  class Gateway
    class BraintreeVzeroBase
      class Address
        attr_reader :user, :request

        def initialize(gateway, order)
          @gateway = gateway
          @order = order
          @user = order.user
          @request = gateway.provider::Address
        end

        def utils
          @_utils ||= Utils.new(@gateway, @order)
        end

        def create
          @request.create(utils.address_data('billing', utils.order).merge!(customer_id: user.id.to_s))
        end

        def find(braintree_address)
          address_id = braintree_address.try(:id) || braintree_address
          @request.find(user.id.to_s, address_id.to_s)
        rescue Braintree::NotFoundError
        end

        def update(braintree_address, params)
          @request.update(user.id.to_s, braintree_address.id.to_s, params)
        end

        def delete(braintree_address)
          @request.delete(user.id.to_s, braintree_address.id.to_s)
        end
      end
    end
  end
end
