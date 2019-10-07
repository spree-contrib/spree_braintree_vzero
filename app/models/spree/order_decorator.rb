module Spree
  module OrderDecorator
    def self.prepended(base)
      base.state_machine.before_transition to: :complete, do: :process_paypal_express_payments
    end

    def save_paypal_address(type, address_hash)
      return if address_hash.blank?
      address = Spree::Address.new(prepare_address_hash(address_hash))
      return unless address.save

      update_column("#{type}_id", address.id)
    end

    def save_paypal_payment(options)
      options[:source] = Spree::BraintreeCheckout.create!(options.slice(:paypal_email, :advanced_fraud_data))
      payments.create(options.slice(:braintree_nonce, :payment_method_id, :source))
    end

    def set_billing_address
      return if bill_address_id
      return unless ship_address_id

      address = Spree::Address.create(shipping_address.attributes.except('id', 'updated_at', 'created_at', 'braintree_id'))
      update_column(:bill_address_id, address.try(:id))
    end

    # override needed to add braintree source attribute
    def update_from_params(params, permitted_params, request_env = {})
      success = false
      @updating_params = params
      run_callbacks :updating_from_params do
        # Set existing card after setting permitted parameters because
        # rails would slice parameters containg ruby objects, apparently
        existing_card_id = @updating_params[:order] ? @updating_params[:order].delete(:existing_card) : nil

        attributes = @updating_params[:order] ? @updating_params[:order].permit(permitted_params).delete_if { |_k, v| v.nil? } : {}
        payment_attributes = attributes[:payments_attributes].first if attributes[:payments_attributes].present?

        if existing_card_id.present?
          credit_card = Spree::CreditCard.find existing_card_id
          if credit_card.user_id != user_id || credit_card.user_id.blank?
            raise Spree::Core::GatewayError, Spree.t(:invalid_credit_card)
          end

          credit_card.verification_value = params[:cvc_confirm] if params[:cvc_confirm].present?

          attributes[:payments_attributes].first[:source] = credit_card
          attributes[:payments_attributes].first[:payment_method_id] = credit_card.payment_method_id
          attributes[:payments_attributes].first.delete :source_attributes
        end

        if payment_attributes.present?
          payment_attributes[:request_env] = request_env

          if (token = payment_attributes[:braintree_token]).present?
            payment_attributes[:source] = Spree::BraintreeCheckout.create_from_token(token, payment_attributes[:payment_method_id])
          elsif payment_attributes[:braintree_nonce].present?
            payment_attributes[:source] = Spree::BraintreeCheckout.create_from_params(params)
          end
        end

        success = update(attributes)
        set_shipments_cost if shipments.any?
      end

      @updating_params = nil
      success
    end

    def payment_required?
      # default payment processing requires order to have state == payment
      # so there is no need to divide this method for checkout steps and actual payment processing
      return false if paid_with_paypal_express?
      total.to_f > 0.0
    end

    def confirmation_required?
      Spree::Config[:always_include_confirm_step] ||
        payments.valid.map(&:payment_method).compact.any?(&:payment_profiles_supported?) ||
        # setting payment_profiles_supported? for braintree gateways would require few additional changes in payments profiles system
        braintree_confirmation_required? || state == 'confirm'
    end

    def paid_with_braintree?
      payments.valid.map(&:payment_method).compact.any? { |p| p.is_a?(Spree::Gateway::BraintreeVzeroBase) }
    end

    def paid_with_paypal_express?
      payments.valid.map(&:payment_method).compact.any? { |p| p.is_a?(Spree::Gateway::BraintreeVzeroPaypalExpress) }
    end

    def invalidate_paypal_express_payments
      return unless paid_with_paypal_express?

      payments.valid.each do |payment|
        payment.invalidate! if payment.payment_method.is_a?(Spree::Gateway::BraintreeVzeroPaypalExpress)
      end
    end

    def no_phone_number?
      [ship_address, bill_address].each do |address|
        return true if address.try(:phone).eql?(I18n.t('braintree.phone_number_placeholder'))
      end
      false
    end

    def remove_phone_number_placeholder
      [ship_address, bill_address].each do |address|
        address.update_column(:phone, nil) if address.try(:phone).eql?(I18n.t('braintree.phone_number_placeholder'))
      end
    end

    private

    def braintree_confirmation_required?
      paid_with_braintree? && state.eql?('payment')
    end

    def prepare_address_hash(hash)
      hash.delete_if { |e| hash[e].eql?('undefined') }
      country_id = Spree::Country.find_by(iso: hash.delete(:country)).try(:id)

      hash[:country_id] = country_id
      state_param = hash.delete(:state)
      state = Spree::State.where('spree_states.abbr = :abbr OR upper(spree_states.name) = :name',
                                 abbr: state_param, name: state_param.upcase).find_by(country_id: country_id)
      hash[:state_id] = state.try(:id)
      hash[:phone] ||= I18n.t('braintree.phone_number_placeholder')

      return hash if hash[:full_name].blank?

      full_name = hash.delete(:full_name).split(' ')
      hash[:lastname] = full_name.slice!(-1)
      hash[:firstname] = full_name.join(' ')
      hash
    end

    def process_paypal_express_payments
      return unless paid_with_paypal_express?

      if payments.valid.empty?
        order.errors.add(:base, Spree.t(:no_payment_found))
        false
      else
        payments.valid.last.update(amount: order_total_after_store_credit)
        process_payments!
      end
    end
  end
end

::Spree::Order.prepend(Spree::OrderDecorator)
