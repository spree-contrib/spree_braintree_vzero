module Spree
  class Gateway
    class BraintreeVzeroBase
      class BraintreeUser
        attr_reader :user, :spree_user, :request

        delegate :shipping_address, :billing_address, to: :spree_user

        def initialize(gateway, spree_user, order)
          @spree_user = spree_user
          @order = order
          @gateway = gateway
          @request = gateway.provider::Customer
          begin
            @user = @request.find(spree_user.try(:id))
          rescue
          end
        end

        def utils
          @_utils ||= Utils.new(@gateway, @order)
        end

        def register_user
          @request.create(utils.customer_data(spree_user))
        end
      end
    end
  end
end
