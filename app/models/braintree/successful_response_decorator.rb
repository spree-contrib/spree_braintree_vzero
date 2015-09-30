Braintree::SuccessfulResult.class_eval do
  attr_reader :authorization

  def authorization
    transaction.id
  end
end
