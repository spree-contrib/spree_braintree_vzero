module Braintree
  module SuccessfulResultDecorator
    def self.prepended(base)
      base.mattr_reader :authorization, :message
    end

    def authorization
      transaction.id
    end

    def avs_result
      { code: transaction.avs_street_address_response_code }.with_indifferent_access
    end

    def cvv_result
      { code: transaction.cvv_response_code, message: nil }.with_indifferent_access
    end
  end
end

::Braintree::SuccessfulResult.prepend(Braintree::SuccessfulResultDecorator)
