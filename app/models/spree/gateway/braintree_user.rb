module Spree
  class Gateway
    class BraintreeUser

      attr_reader :user, :spree_user, :request, :utils

      def initialize(provider, spree_user, order)
        @utils = BraintreeUtils.new(provider, order)
        @spree_user = spree_user
        @request = provider::Customer
        begin
          @user = @request.find(spree_user.try(:id))
        rescue
        end
      end

      def register_user
        @request.create(@utils.customer_data(spree_user))
      end

    end
  end
end