module Spree
  class Gateway
    class BraintreeVzeroBase
      class Utils
        attr_reader :order, :customer, :gateway

        def initialize(gateway, order)
          @order = order
          begin
            @customer = gateway.provider::Customer.find(order.user.id) if order.user
          rescue
          end
          @gateway = gateway
        end

        def get_address(address_type)
          if order.user && (address = order.user.send("#{address_type}_address"))
            braintree_address = BraintreeVzeroBase::Address.new(gateway.provider, order)
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
          if @customer
            { customer_id: @customer.id }
          else
            { customer: (payment_in_vault[:store_shipping_address_in_vault] && order.user) ? customer_data(order.user) : {} }
          end
        end

        def order_data(identifier, amount)
          identifier.merge(
            amount: amount,
            order_id: order.number,
            line_items: collect_line_items,
            shipping_amount: order_shipping
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
          payment_methods = @customer.try(:payment_methods) || []

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

          case gateway.preferred_store_payments_in_vault.to_s
          when 'store_only_on_success'
            { store_in_vault_on_success: true, store_shipping_address_in_vault: store_ship_address }
          when 'store_all'
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

        private

        PAYPAL_MAX_LINEITEMS = 249

        def collect_line_items # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          items =
            @order
            .line_items
            .reject { |li| li.price.zero? || li.quantity.zero? }
            .map do |li|
            {
              name: li.name.truncate(127, omission: ''),
              kind: 'debit',
              quantity: li.quantity.to_s,
              unit_amount: li.price.to_s,
              unit_of_measure: 'unit',
              product_code: li.sku,
              total_amount: (li.price * li.quantity).to_s,
              tax_amount: li.additional_tax_total.to_s
            }
          end.
            take(PAYPAL_MAX_LINEITEMS - 1)
          total = @order.adjustment_total.abs
          return items if total.zero?

          items.append({
                         name: 'discount',
                         kind: 'credit',
                         quantity: '1',
                         unit_amount: total.to_s,
                         total_amount: total.to_s
                       })
        end

        def order_shipping
          @order.shipment_total.to_s
        end
      end
    end
  end
end
