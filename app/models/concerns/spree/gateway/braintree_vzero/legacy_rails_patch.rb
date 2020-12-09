module Spree
  class Gateway
    module BraintreeVzero
      module LegacyRailsPatch
        extend ActiveSupport::Concern

        private

        # https://github.com/spree-contrib/spree_braintree_vzero/issues/216
        def method_name_for_attributes_after_save
          Rails::VERSION::STRING >= '5.1' ? :saved_changes : :changes
        end

        def attributes_after_save
          method(method_name_for_attributes_after_save).call
        end
      end
    end
  end
end
