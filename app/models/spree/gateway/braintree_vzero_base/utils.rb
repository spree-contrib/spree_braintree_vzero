module Spree
  class Gateway
    class BraintreeVzeroBase
      class Utils
        attr_reader :order, :gateway

        def initialize(gateway, order)
          @order = order
          @gateway = gateway
        end

        def customer
          @customer ||= gateway.provider::Customer.find(order.user.id) if order.user
        rescue Braintree::NotFoundError
          nil
        end

        def get_address(address_type)
          if order.user && (address = order.user.send("#{address_type}_address"))
            braintree_address = BraintreeVzeroBase::Address.new(gateway, order)
            vaulted_duplicate = Spree::Address.vaulted_duplicates(address).first

            if vaulted_duplicate && braintree_address.find(vaulted_duplicate.braintree_id)
              { "#{address_type}_address_id" => vaulted_duplicate.braintree_id }
            else
              { address_type => address_data(address_type, order.user) }
            end
          else
            { address_type => address_data(address_type, order) }
          end
        end

        def get_customer
          if customer
            { customer_id: customer.id }
          else
            { customer: (payment_in_vault[:store_shipping_address_in_vault] && order.user) ? customer_data(order.user) : {} }
          end
        end

        def order_data(identifier, amount)
          identifier.merge(
            amount: amount,
            order_id: order.number
          )
        end

        def address_data(address_type, target)
          address = target.send("#{address_type}_address")
          country = address.country

          {
            company: address.company,
            country_code_alpha2: country.iso,
            country_code_alpha3: country.iso3,
            country_code_numeric: country.numcode,
            country_name: country.name,
            first_name: address.first_name,
            last_name: address.last_name,
            locality: address.city,
            postal_code: address.zipcode,
            region: address.state.try(:abbr),
            street_address: address.address1,
            extended_address: address.address2
          }
        end

        def customer_data(user)
          address_data('billing', user).slice(:first_name, :last_name, :company, :phone).merge!(id: user.id, email: user.email)
        end

        def customer_payment_methods(payment_method_type)
          payment_methods = customer.try(:payment_methods) || []

          if payment_method_type.eql?('custom')
            payment_methods.select { |pm| pm.is_a?(Braintree::CreditCard) }
          elsif payment_method_type.eql?('paypal')
            payment_methods.select { |pm| pm.is_a?(Braintree::PayPalAccount) }
          else
            payment_methods
          end
        end

        def payment_in_vault(data = {})
          store_ship_address = data['shipping_address_id'].blank?
          if gateway.preferred_store_payments_in_vault == 'store_only_on_success'
            { store_in_vault_on_success: true, store_shipping_address_in_vault: store_ship_address }
          elsif gateway.preferred_store_payments_in_vault == 'store_all'
            { store_in_vault: true, store_shipping_address_in_vault: store_ship_address }
          else
            { store_in_vault: false }
          end
        end

        def map_payment_status(braintree_status)
          case braintree_status
          when 'authorized', 'settlement_pending'
            'pending'
          when 'voided'
            'void'
          when 'settled', 'submitted_for_settlement', 'settling'
            'completed'
          else
            'failed'
          end
        end
      end
    end
  end
end
