Braintree::SuccessfulResult.class_eval do
  attr_reader :authorization

  def authorization
    transaction.id
  end

  def avs_result
    { code: transaction.avs_street_address_response_code }
  end

  def cvv_result
    { code: transaction.cvv_response_code, message: nil }
  end
end
