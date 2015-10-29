module Spree
  class BraintreeCheckout < ActiveRecord::Base

    scope :in_state, ->(state) { where(state: state) }
    scope :not_in_state, ->(state) { where.not(state: state) }

    after_save :update_payment_and_order

    FINAL_STATES = %w(authorization_expired processor_declined gateway_rejected failed voided settled settlement_declined refunded released)

    has_one :payment, foreign_key: :source_id, inverse_of: :source
    has_one :order, through: :payment

    def self.update_states
      braintree = Gateway::BraintreeVzeroDropInUI.first.provider
      result = {changed: 0, unchanged: 0}
      self.not_in_state(FINAL_STATES).find_each do |checkout|
        checkout.state = braintree::Transaction.find(checkout.transaction_id).status
        if checkout.state_changed?
          result[:changed] += 1
          checkout.save
        else
          result[:unchanged] += 1
        end
      end
      result
    end

    def update_state
      status = Transaction.new(Gateway::BraintreeVzeroDropInUI.first.provider, transaction_id).status
      self.update_attribute(:state, status)
      status
    end

    def actions
      %w(void settle credit)
    end

    def can_void?(_payment)
      %w(authorized submitted_for_settlement).include? state
    end

    def can_settle?(_)
      %w(authorized).include? state
    end

    def can_credit?(_payment)
      %w(settled settling).include? state
    end

    private

    def update_payment_and_order
      if state_changed? && payment
        payment.update_attribute(:state, Gateway::BraintreeVzeroBase::Utils.new(Gateway::BraintreeVzeroDropInUI.first, order).map_payment_status(state))
        order.update!
      end
    end

  end
end
