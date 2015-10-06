module Spree
  Address.class_eval do


    def same_as?(other)
      return false if other.nil?
      attributes.except('id', 'updated_at', 'created_at', 'braintree_id') == other.attributes.except('id', 'updated_at', 'created_at', 'braintree_id')
    end

  end
end