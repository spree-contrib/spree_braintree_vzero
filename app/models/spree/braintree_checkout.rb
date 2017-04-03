module Spree
  class BraintreeCheckout < ActiveRecord::Base
    scope :in_state, ->(state) { where(state: state) }
    scope :not_in_state, ->(state) { where.not(state: state) }

    after_commit :update_payment_and_order

    FINAL_STATES = %w(authorization_expired processor_declined gateway_rejected failed voided settled settlement_declined refunded released).freeze

    has_one :payment, foreign_key: :source_id, as: :source, class_name: 'Spree::Payment'
    has_one :order, through: :payment

    def self.create_from_params(params)
      type = braintree_card_type_to_spree(params[:braintree_card_type])
      create!(paypal_email: params[:paypal_email],
              braintree_last_digits: params[:braintree_last_two],
              braintree_card_type: type)
    end

    def self.create_from_token(token, payment_method_id)
      gateway = Spree::PaymentMethod.find(payment_method_id)
      vaulted_payment_method = gateway.vaulted_payment_method(token)
      type = braintree_card_type_to_spree(vaulted_payment_method.try(:card_type))
      create!(paypal_email: vaulted_payment_method.try(:email),
              braintree_last_digits: vaulted_payment_method.try(:last_4),
              braintree_card_type: type)
    end

    def self.update_states
      braintree = Gateway::BraintreeVzeroBase.first.provider
      result = { changed: 0, unchanged: 0 }
      not_in_state(FINAL_STATES).find_each do |checkout|
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
      status = Transaction.new(Gateway::BraintreeVzeroBase.first.provider, transaction_id).status
      payment.send(payment_action(status))
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
      return unless (changes = previous_changes[:state])
      return unless changes[0] != changes[1]
      return unless payment

      utils = Gateway::BraintreeVzeroBase::Utils.new(Gateway::BraintreeVzeroBase.first, order)
      payment_state = utils.map_payment_status(state)
      payment.send(payment_action(payment_state))
    end

    def self.braintree_card_type_to_spree(type)
      return '' unless type
      case type
      when 'AmericanExpress'
        'american_express'
      when 'Diners Club'
        'diners_club'
      when 'MasterCard'
        'master'
      else
        type.downcase
      end
    end

    def payment_action(state)
      case state
      when 'pending'
        'pend'
      when 'void'
        'void'
      when 'completed'
        'complete'
      else
        'failure'
      end
    end
  end
end
