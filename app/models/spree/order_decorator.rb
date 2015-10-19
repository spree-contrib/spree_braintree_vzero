Spree::Order.class_eval do
  def save_paypal_address(type, address_hash)
    return if address_hash.blank?

    update_column("#{type}_id", Spree::Address.create(prepare_address_hash(address_hash)).id)
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

      if existing_card_id.present?
        credit_card = CreditCard.find existing_card_id
        if credit_card.user_id != user_id || credit_card.user_id.blank?
          raise Core::GatewayError.new Spree.t(:invalid_credit_card)
        end

        credit_card.verification_value = params[:cvc_confirm] if params[:cvc_confirm].present?

        attributes[:payments_attributes].first[:source] = credit_card
        attributes[:payments_attributes].first[:payment_method_id] = credit_card.payment_method_id
        attributes[:payments_attributes].first.delete :source_attributes
      end

      if attributes[:payments_attributes].present? && (attributes[:payments_attributes].first[:braintree_token].present? || attributes[:payments_attributes].first[:braintree_nonce].present?)
        attributes[:payments_attributes].first[:source] = Spree::BraintreeCheckout.create!
      end

      if attributes[:payments_attributes]
        attributes[:payments_attributes].first[:request_env] = request_env
      end

      success = update_attributes(attributes)
      set_shipments_cost if shipments.any?
    end

    @updating_params = nil
    success
  end

  # def confirmation_required?
  #   Spree::Config[:always_include_confirm_step] ||
  #       payments.valid.map(&:payment_method).compact.any?(&:payment_profiles_supported?) ||
  #       state == 'confirm' ||
  #       payments.valid.map(&:payment_method).compact.any?{ |p| p.is_a?(Spree::Gateway::BraintreeVzeroStandard) }
  # end

  private

  def prepare_address_hash(hash)
    country_id = Spree::Country.find_by(iso: hash.delete(:country)).id

    hash[:country_id] = country_id
    hash[:state_id] = Spree::State.find_by(abbr: hash.delete(:state), country_id: country_id).id

    return hash if hash[:full_name].blank?

    full_name = hash.delete(:full_name).split(' ')
    hash[:lastname] = full_name.slice!(-1)
    hash[:firstname] = full_name.join(' ')
    hash
  end
end
